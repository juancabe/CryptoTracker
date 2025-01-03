//
//  CryptoRetrieveService.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import Foundation
import KeychainAccess

class CryptoRetrieveService {
    private let baseURL: URL = URL(string: "https://api.coingecko.com/api/v3")!
    
    // Singleton
    static private let shared = CryptoRetrieveService()
    public static func getInstance() -> CryptoRetrieveService {
        return shared
    }
    
    private var allCoinsBasic: [BasicCrypto] = []
    private var pastCoinData: [CryptocurrencyData] = []
    
    // Keychain constants
    private let bundleName = "juancabe.CryptoTracker"
    private let keyValue = "apiKey"
    private let keychain: Keychain
    
    private init(){
        self.keychain = Keychain(service: bundleName)
    }
    
    // API KEY RELATED FUNCTIONS
    
    public func getAPIKey() -> String? {
        self.keychain[keyValue]
    }
    
    public func saveAPIKey(apiKey: String?) {
        self.keychain[keyValue] = apiKey
    }
    
    public func testAPIKey() async -> Bool {
        if let apiKey = getAPIKey() {
            return await CryptoRetrieveService.getInstance().testApiKey(apiKey: apiKey)
        } else {
            debugPrint("API key not found")
            return false
        }
    }
    
    // Public function that returns to the user allCoinsBasic data
    func getAllCoinsBasic(apiKey: String?) async -> [BasicCrypto] {
        if !allCoinsBasic.isEmpty { // If data exists, return alredy fetched data
            return allCoinsBasic
        } else {
            let res = await _getAllCoinsBasic(apiKey: apiKey) // Fetch data
            if let res {
                allCoinsBasic = res
                return allCoinsBasic
            } else {
                allCoinsBasic = [] // If failed, return empty array
                return allCoinsBasic
            }
        }
    }
    
    private func _getAllCoinsBasic(apiKey: String?) async -> [BasicCrypto]? {
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/list")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.addValue("application/json", forHTTPHeaderField: "accept")
        if let apiKey { // If API key is provided, use it.
            request.addValue(apiKey, forHTTPHeaderField: "x-cg-demo-api-key")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode([[String: String]].self, from: data)
            
            // Map the response to BasicCrypto objects and limit to maxResults
            let basicCoins = decodedResponse.compactMap { coin in
                if let id = coin["id"], let name = coin["name"], let symbol = coin["symbol"] {
                    return BasicCrypto(id: id, name: name, symbol: symbol)
                }
                return nil
            }
            
            return basicCoins
        } catch {
            print("Error fetching coins: \(error.localizedDescription)")
            return nil
        }
    }
    
    func cryptoInfo(id: String, curr: CurrencyInfo, isSaved: Bool = false, isFavorite: Bool, apiKey: String?, force: Bool = false) async -> CryptoInfo? {
        if(id.isEmpty) {
            return nil
        }
        if !force { // Check wether user specifies to update data even if it was recently fetched
            for data in pastCoinData {
                if(data.id == id) { // If data was recently fetched, return that chached data
                    return CryptoInfo(data: data, curr: curr, isSaved: isSaved, isFavorite: isFavorite)
                }
            }
        }
        
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.addValue("application/json", forHTTPHeaderField: "accept")
        if let apiKey {
            request.addValue(apiKey, forHTTPHeaderField: "x-cg-demo-api-key")
        }
        
        debugPrint("Fetching url: \(url)")
        
        guard let receivedData = await sendRequest(request: request) else {
            debugPrint("[cryptoInfo] Networking error")
            return nil
        }
        
        guard let decoded: CryptocurrencyData = await decodeData(receivedData: receivedData) else {
            debugPrint("[cryptoInfo] Decoding error")
            return nil
        }
        pastCoinData.append(decoded) // Append to chached data
        return CryptoInfo(data: decoded, curr: curr, isSaved: isSaved, isFavorite: isFavorite)
        
    }
    
    // Returns marketData for specific crypto and for specific amount of days
    func marketData(id: String, curr: CurrencyInfo, days: Int, apiKey: String?) async -> MarketData? {
        
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(id)/market_chart")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "vs_currency", value: curr.currencyRepresentation),
            URLQueryItem(name: "days", value: String(days)),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        if let apiKey {
            request.allHTTPHeaderFields = [
              "accept": "application/json",
              "x-cg-demo-api-key": apiKey // If API key is specified, use it
            ]
        } else {
            request.allHTTPHeaderFields = [
              "accept": "application/json"
            ]
        }
        
        debugPrint("Fetching url \(components.url!)")
        
        guard let receivedData = await sendRequest(request: request) else {
            debugPrint("[marketData] Networking error")
            return nil
        }
        
        guard let marketData: MarketData = await decodeData(receivedData: receivedData) else {
            debugPrint("[marketData] Decoding error")
            return nil
        }
        
        debugPrint("[marketData] Successfully fetched market data")
        return marketData 
    }
    
    func cryptoPrice(id: String, curr: CurrencyInfo, apiKey: String?) async -> Double? {
        let url = URL(string: "https://api.coingecko.com/api/v3/simple/price")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "ids", value: id),
          URLQueryItem(name: "vs_currencies", value: curr.currencyRepresentation),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        
        if let apiKey {
            request.allHTTPHeaderFields = [
              "accept": "application/json",
              "x-cg-demo-api-key": apiKey
            ]
        } else {
            request.allHTTPHeaderFields = [
              "accept": "application/json",
            ]
        }
        
        debugPrint("Fetching url \(components.url!)")
        
        guard let receivedData = await sendRequest(request: request) else {
            debugPrint("[marketData] Networking error")
            return nil
        }
        
        let receivedDataString = String(data: receivedData, encoding: .utf8)!
        debugPrint("Received data: \(receivedDataString)")
        return getPrice(curr: curr.currencyRepresentation, data: receivedDataString)
    }

    private func getPrice(curr: String, data: String) -> Double? {
        // Construct regex pattern to match the "curr" key and capture its value
        let pattern = "\"\(curr)\"\\s*:\\s*(\\d+(\\.\\d+)?)"
        
        // Create the regular expression
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            print("Invalid regex pattern.")
            return nil
        }
        
        // Define the range for the search
        let range = NSRange(location: 0, length: data.utf16.count)
        
        // Search for the first match
        if let match = regex.firstMatch(in: data, options: [], range: range) {
            // Extract the captured value
            if let priceRange = Range(match.range(at: 1), in: data) {
                let priceString = String(data[priceRange])
                if let price = Double(priceString) {
                    return price
                }
            }
        }
        
        // Return 0.0 if no match is found or conversion fails
        return nil
    }
    
    // Send req and return Data
    private func sendRequest(request: URLRequest) async -> Data? {
        var receivedData: Data? = nil
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            receivedData = data
        } catch {
            print("Couldn't get a proper response: \(error)")
            return nil
        }
        
        
        return receivedData
    }
    
    // Decode data
    private func decodeData<T: Decodable>(receivedData: Data) async -> T? {
        // Decode
        let decoder = JSONDecoder()

        // Custom date decoding strategy
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Attempt multiple date formats
            let iso8601FormatterWithFractionalSeconds = ISO8601DateFormatter()
            iso8601FormatterWithFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let iso8601FormatterWithoutFractionalSeconds = ISO8601DateFormatter()
            iso8601FormatterWithoutFractionalSeconds.formatOptions = [.withInternetDateTime]

            if let date = iso8601FormatterWithFractionalSeconds.date(from: dateString) {
                return date
            } else if let date = iso8601FormatterWithoutFractionalSeconds.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected ISO8601 date format with or without fractional seconds."
            )
        }
        
        do {
            let crypto = try decoder.decode(T.self, from: receivedData)
            return crypto
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
    
    // Function to test wether certain API key is valid or not
    func testApiKey(apiKey: String) async -> Bool {
        let url = URL(string: "https://api.coingecko.com/api/v3/ping")!
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "x-cg-demo-api-key")
        
        do {
            debugPrint("ping with key: \(apiKey)")
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            } else {
                debugPrint("Bad response")
                return false
            }
        } catch {
            return false
        }
    }
}
