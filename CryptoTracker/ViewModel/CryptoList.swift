//
//  CryptoList.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import Foundation
import SwiftData

struct CryptoInfo : Identifiable {
    var id: UUID = UUID()
    let name: String
    let symbol: String
    let price: String
    let marketCap: String
    let imageUrl: URL
    let priceChange: String
    let isFavorite: Bool
    
    init(name: String, symbol: String, price: String, marketCap: String, imageUrl: URL, priceChange: String, isFavorite: Bool) {
        self.name = name
        self.symbol = symbol
        self.price = price
        self.marketCap = marketCap
        self.imageUrl = imageUrl
        self.priceChange = priceChange
        self.isFavorite = isFavorite
    }
}

@Observable
class CryptoList : ObservableObject {
    
    private var modelContext: ModelContext?
    private var favorites: [FavoriteCrypto] = [FavoriteCrypto]()
    private var allCryptoData: [CryptocurrencyData] = [CryptocurrencyData]()
    public var cryptoList: [CryptoInfo] = [CryptoInfo]()
    
    private let currecncy = "usd"
    private let maxResults = 100
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchFavorites()
        fetchAllCryptoData()
    }
    
    init() {
        self.modelContext = nil;
    }
    
    private func fetchFavorites() {
        do{
            try favorites = modelContext!.fetch(FetchDescriptor<FavoriteCrypto>())
        }
        catch {
            debugPrint("Error fetching favorites: \(error)")
        }
    }
    
    private func buildCryptoList() {
        cryptoList.removeAll()
        for data in allCryptoData {
            cryptoList.append(CryptoInfo(name: data.name,
                                         symbol: data.symbol.uppercased(),
                                         price: String(data.currentPrice),
                                         marketCap: String(data.marketCap),
                                         imageUrl: data.image,
                                         priceChange: String(data.priceChange24h),
                                         isFavorite: favorites
                   .contains(where: { $0.symbol.lowercased() == data.symbol.lowercased() })
                                ))
        }
    }
    
    private func fetchAllCryptoData() {
        Task {
            if let data = await CryptoRetrieveService.getInstance()
                .getAllCoins(currency: currecncy, maxResults: maxResults) {
                allCryptoData = data
            } else {
                allCryptoData = []
            }
            buildCryptoList()
        }
    }
    
    public func addItem() {
        let newItem = FavoriteCrypto(name: "New Favorite", symbol: "NEW")
        if let mc = modelContext {
            mc.insert(newItem)
        }
        debugPrint("Inserted new item")
        fetchFavorites()
    }

    public func deleteItems(offsets: IndexSet) {
        if let mc = modelContext {
            for index in offsets {
                mc.delete(favorites[index])
            }
        }
        debugPrint("Deleted items")
        fetchFavorites()
    }
    
}
