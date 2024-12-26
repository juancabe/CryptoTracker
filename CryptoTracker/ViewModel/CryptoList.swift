//
//  CryptoList.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import Foundation
import SwiftData

struct CurrencyInfo {
    let currencyRepresentation: String
    let currencySymbol: String
    
    init(currencyRepresentation: String, currencySymbol: String) {
        self.currencyRepresentation = currencyRepresentation
        self.currencySymbol = currencySymbol
    }
    
    init() {
        self.currencyRepresentation = "currencyRepresentation"
        self.currencySymbol = "currencySymbol"
    }
}

class CryptoInfo : Identifiable, ObservableObject {
    var id: UUID = UUID()
    let name: String
    let symbol: String
    let price: String
    let marketCap: String
    let imageUrl: URL?
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
    
    init(data: CryptocurrencyData, curr: CurrencyInfo, isFavorite: Bool) {
        self.name = data.name
        self.symbol = data.symbol.uppercased()
        
        if let price = data.market_data.current_price[curr.currencyRepresentation] {
            self.price = String(price) + curr.currencySymbol
        } else {
            self.price = "No price provided for " + curr.currencySymbol
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
        self.isFavorite = isFavorite

    }
    
    init() {
        self.name = "name"
        self.symbol = "symbol"
        self.price = "price"
        self.marketCap = "marketCap"
        self.imageUrl = URL(filePath: "imageUrl.com")!
        self.priceChange = "priceChange"
        self.isFavorite = false
    }
}

@Observable
class CryptoList : ObservableObject {
    
    var isLoaded: Bool = false
    private var modelContext: ModelContext?
    
    var favorites: [FavoriteCrypto] = [FavoriteCrypto]()
    var allCryptoBasic: [BasicCrypto] = [BasicCrypto]()
    var cryptoFavoritesInfo: [CryptoInfo] = [CryptoInfo]()
    
    let currency: CurrencyInfo = CurrencyInfo(currencyRepresentation: "usd", currencySymbol: "$")
    
    private let maxResults = 20
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            fetchFavorites()
            await fetchAllCryptoBasic()
            isLoaded = true
        }
        
    }
    
    init() {self.modelContext = nil;}
    
    private func fetchFavorites() {
        do{
            try favorites = modelContext!.fetch(FetchDescriptor<FavoriteCrypto>())
        }
        catch {
            debugPrint("Error fetching favorites: \(error)")
        }
    }
    
    private func buildCryptoList() async {
        cryptoFavoritesInfo.removeAll()
        debugPrint("data.count: \(allCryptoBasic.count)")
        debugPrint("favorites.count: \(favorites.count)")
        for data in allCryptoBasic {
            let isFav = favorites.contains(
                where: {
                    $0.id == data.id
                })
            
            if isFav {
                debugPrint("\(data.id) is favorite")
                if let info = await CryptoRetrieveService.getInstance().cryptoInfo(id: data.id, curr: currency, isFavorite: isFav) {
                    cryptoFavoritesInfo.append(info)
                } else {
                    debugPrint("[buildCryptoList] couldn't retrieve info for \(data.id)")
                }
            }
        }
    }
    
    private func fetchAllCryptoBasic() async {
        allCryptoBasic = await CryptoRetrieveService.getInstance().getAllCoinsBasic()
        await buildCryptoList()
    }
    
    public func addFavorite(id: String) {
        let newItem = FavoriteCrypto(id: id)
        if let mc = modelContext {
            mc.insert(newItem)
            do {
                try mc.save()
            } catch {
                debugPrint("MC couldn't be saved")
            }
        }
        debugPrint("Inserted new item")
        fetchFavorites()
        Task {
            if let info = await CryptoRetrieveService.getInstance().cryptoInfo(id: id, curr: currency) {
                cryptoFavoritesInfo.append(info)
                debugPrint("Inserted favorite info")
            } else {
                debugPrint("Error inserting favorite info")
            }
        }
    }

    public func deleteFavorites(offsets: IndexSet) {
        if let mc = modelContext {
            for index in offsets {
                mc.delete(favorites[index])
            }
            do {
                try mc.save()
            } catch {
                debugPrint("MC couldn't be saved")
            }
        }
        debugPrint("Deleted items")
        fetchFavorites()
        Task {
            await buildCryptoList()
        }
        
    }
}
