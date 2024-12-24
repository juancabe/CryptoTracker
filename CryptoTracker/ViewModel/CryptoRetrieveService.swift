//
//  CryptoRetrieveService.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import Foundation

class CryptoRetrieveService {
    private let baseURL: URL = URL(string: "https://api.coingecko.com/api/v3")!
    
    // Singleton
    static private var lastReqTime: Date? = nil
    static private let shared = CryptoRetrieveService()
    public static func getInstance() -> CryptoRetrieveService {
        if let lastReqTime = lastReqTime, Date().timeIntervalSince(lastReqTime) < 1 {
            return shared
        }
        lastReqTime = Date()
        return shared
    }
    private init(){}
    
    func getAllCoins(currency: String, maxResults: Int) async -> [CryptocurrencyData]? {
        // Include the `vs_currency` query parameter
        let baseURL = "https://api.coingecko.com/api/v3/coins/markets"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: currency), // Required parameter
            URLQueryItem(name: "order", value: "market_cap_desc"), // order by market cap
            URLQueryItem(name: "per_page", value: String(maxResults)), // limit results per page to maxResults
            URLQueryItem(name: "page", value: "1"), // specify the page
            URLQueryItem(name: "sparkline", value: "false") // exclude sparkline data
        ]

        guard let url = components.url else {
            print("Failed to construct URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        
        var receivedData: Data? = nil
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            receivedData = data
        } catch {
            print("Couldn't get a proper response: \(error)")
            return nil
        }
        
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
            let crypto = try decoder.decode([CryptocurrencyData].self, from: receivedData!)
            return crypto
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
}
