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
    
    private init(){}
    
    func getAllCoinsBasic() async -> [BasicCrypto] {
        if let allCoinsBasic {
            return allCoinsBasic
        } else {
            allCoinsBasic = await _getAllCoinsBasic()
            if let allCoinsBasic {
                return allCoinsBasic
            } else {
                allCoinsBasic = []
                return []
            }
        }
    }
    
    private func _getAllCoinsBasic() async -> [BasicCrypto]? {
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/list")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
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
    
    func cryptoInfo(id: String, curr: CurrencyInfo, isFavorite: Bool = false) async -> CryptoInfo? {
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json"
        ]
        
        debugPrint("Fetching url: \(url)")
        
        guard let receivedData = await sendRequest(request: request) else {
            debugPrint("[cryptoInfo] Networking error")
            return nil
        }
        
        guard let decoded: CryptocurrencyData = await decodeData(receivedData: receivedData) else {
            debugPrint("[cryptoInfo] Decoding error")
            return nil
        }
        return CryptoInfo(data: decoded, curr: curr, isFavorite: isFavorite)
        
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
}
