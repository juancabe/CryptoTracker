//
//  CryptoInfo.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 27/12/24.
//

import Foundation

@Observable
class CryptoInfo : Identifiable, ObservableObject {
    let id: UUID = UUID()
    let api_id: String
    let name: String
    let symbol: String
    let price: String
    let marketCap: String
    let imageUrl: URL?
    let priceChange: String
    var isSaved: Bool
    var isFavorite: Bool
    
    init(name: String, symbol: String, price: String, marketCap: String, imageUrl: URL, priceChange: String, isSaved: Bool, api_id: String, isFavorite: Bool) {
        self.name = name
        self.symbol = symbol
        self.price = price
        self.marketCap = marketCap
        self.imageUrl = imageUrl
        self.priceChange = priceChange
        self.isSaved = isSaved
        self.api_id = api_id
        self.isFavorite = isFavorite
    }
    
    init(data: CryptocurrencyData, curr: CurrencyInfo, isSaved: Bool, isFavorite: Bool) {
        self.name = data.name
        self.symbol = data.symbol.uppercased()
        
        if let price = data.market_data.current_price[curr.currencyRepresentation] {
            self.price = String(price) + curr.currencySymbol
        } else {
            self.price = "No price provided for " + curr.currencyRepresentation
        }
        
        if let mcap = data.market_data.market_cap[curr.currencyRepresentation] {
            self.marketCap = String(format: "%.3f",mcap/1000000000000) + "B " + curr.currencySymbol.uppercased()
        } else {
            self.marketCap = "No market cap provided"
        }
        
        if let img = URL(string: data.image.large) {
            self.imageUrl = img
        } else {
            self.imageUrl = nil
        }
        
        self.priceChange = String(format: "%.2f", data.market_data.price_change_percentage_24h) + "%"
        self.isSaved = isSaved
        self.api_id = data.id
        self.isFavorite = isFavorite

    }
    
    init() {
        self.name = "name"
        self.symbol = "symbol"
        self.price = "price"
        self.marketCap = "marketCap"
        self.imageUrl = URL(filePath: "imageUrl.com")!
        self.priceChange = "priceChange"
        self.isSaved = false
        self.api_id = "api_id"
        self.isFavorite = false
    }
}
