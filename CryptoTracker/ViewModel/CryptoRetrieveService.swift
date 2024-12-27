//
//  CryptoRetrieveService.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import Foundation

struct BasicCrypto : Hashable {
    let id: String
    let name: String
    let symbol: String
    
    init(id: String, name: String, symbol: String) {
        self.id = id
        self.name = name
        self.symbol = symbol
    }
}

class CryptoRetrieveService {
    private let baseURL: URL = URL(string: "https://api.coingecko.com/api/v3")!
    
    // Singleton
    static private let shared = CryptoRetrieveService()
    public static func getInstance() -> CryptoRetrieveService {
        return shared
    }
    
    private var allCoinsBasic: [BasicCrypto]? = nil
    private var pastCoinData: [CryptocurrencyData] = []
    
    private init(){}
    
    func getAllCoinsBasic(apiKey: String?) async -> [BasicCrypto] {
        if let allCoinsBasic {
            return allCoinsBasic
        } else {
            allCoinsBasic = await _getAllCoinsBasic(apiKey: apiKey)
            if let allCoinsBasic {
                return allCoinsBasic
            } else {
                allCoinsBasic = []
                return []
            }
        }
    }
    
    private func _getAllCoinsBasic(apiKey: String?) async -> [BasicCrypto]? {
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/list")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.addValue("application/json", forHTTPHeaderField: "accept")
        if let apiKey {
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
    
    func cryptoInfo(id: String, curr: CurrencyInfo, isSaved: Bool = false, isFavorite: Bool, apiKey: String?) async -> CryptoInfo? {
        
        if(id.isEmpty) {
            return nil
        }
        
        for data in pastCoinData {
            if(data.id == id) {
                return CryptoInfo(data: data, curr: curr, isSaved: isSaved, isFavorite: isFavorite)
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
        pastCoinData.append(decoded)
        return CryptoInfo(data: decoded, curr: curr, isSaved: isSaved, isFavorite: isFavorite)
        
    }
    
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
              "x-cg-demo-api-key": apiKey
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
