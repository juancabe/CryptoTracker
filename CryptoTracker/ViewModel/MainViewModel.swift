//
//  MainViewModelSpacer().swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import Foundation
import SwiftData
import KeychainAccess
import SwiftUICore

@Observable
class MainViewModel : ObservableObject {
    
    private let bundleName = "juancabe.CryptoTracker"
    private let keyValue = "apiKey"
    private let keychain: Keychain
    
    var isLoaded: Bool = false
    private var modelContext: ModelContext?
    
    var savedCrypto: [SavedCrypto] = [SavedCrypto]()
    var allCryptoBasic: [BasicCrypto] = [BasicCrypto]()
    var cryptoSavedInfo: [CryptoInfo] = [CryptoInfo]()
    
    private let defaults = UserDefaults.standard
    var currency: CurrencyInfo
    
    private let maxResults = 20
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.keychain = Keychain(service: bundleName)
        if let value = defaults.string(forKey: "currency") {
            currency = CurrencyInfo(value)
        } else {
            currency = CurrencyInfo("usd")
        }
        Task {
            fetchSaved()
            await fetchAllCryptoBasic()
            isLoaded = true
        }
        
    }
    
    init() {
        self.modelContext = nil
        self.keychain = Keychain(service: bundleName)
        self.currency = CurrencyInfo("usd")
    }
    
    func getCurrencyInfo() -> CurrencyInfo {
        return currency
    }
    
    func setCurrencyInfo(_ currency: CurrencyInfo) {
        self.currency = currency
        fetchSaved()
        defaults.set(currency.currencyRepresentation, forKey: "currency")
        Task {
            await buildCryptoList()
        }
    }
    
    private func fetchSaved() {
        do{
            try savedCrypto = modelContext!.fetch(FetchDescriptor<SavedCrypto>())
        }
        catch {
            debugPrint("Error fetching saved crypto: \(error)")
        }
    }
    
    private func buildCryptoList() async {
        cryptoSavedInfo.removeAll()
        debugPrint("data.count: \(allCryptoBasic.count)")
        debugPrint("savedCrypto.count: \(savedCrypto.count)")
        for data in allCryptoBasic {
            
            if let index = savedCrypto.firstIndex(where: {
                $0.id == data.id
            }) {
                let isFavorite: Bool = savedCrypto[index].favorite
                if let info = await CryptoRetrieveService.getInstance().cryptoInfo(id: data.id, curr: currency, isSaved: true, isFavorite: isFavorite, apiKey: getAPIKey()) {
                    cryptoSavedInfo.append(info)
                } else {
                    debugPrint("[buildCryptoList] couldn't retrieve info for \(data.id)")
                }
            }
        }
    }
    
    private func fetchAllCryptoBasic() async {
        allCryptoBasic = await CryptoRetrieveService.getInstance().getAllCoinsBasic(apiKey: getAPIKey())
        await buildCryptoList()
    }
    
    public func addSaved(id: String) {
        let newItem = SavedCrypto(id: id)
        if let mc = modelContext {
            mc.insert(newItem)
            do {
                try mc.save()
            } catch {
                debugPrint("MC couldn't be saved")
            }
        }
        debugPrint("Inserted new item")
        fetchSaved()
        Task {
             if let info = await CryptoRetrieveService.getInstance().cryptoInfo(id: id, curr: currency, isFavorite: newItem.favorite, apiKey: getAPIKey()) {
                 cryptoSavedInfo.append(info)
                 debugPrint("Inserted saved info")
             } else {
                 debugPrint("Error inserting saved info")
             }
         }
        
    }

    public func deleteSaved(offsets: IndexSet) {
        if let mc = modelContext {
            for index in offsets {
                let id = cryptoSavedInfo[index].api_id
                if let savedI = savedCrypto.firstIndex(where: { $0.id == id }) {
                    debugPrint("Deleting saved \(savedCrypto[savedI].id)")
                    mc.delete(savedCrypto[savedI])
                }
            }
            do {
                try mc.save()
            } catch {
                debugPrint("MC couldn't be saved")
            }
        }
        debugPrint("Deleted items")
        fetchSaved()
        Task {
            await buildCryptoList()
        }
    }
    
    
    public func deleteSaved(obj: CryptoInfo) {
        if let mc = modelContext {
            let id = obj.api_id
            if let savedI = savedCrypto.firstIndex(where: { $0.id == id }) {
                debugPrint("Deleting saved \(savedCrypto[savedI].id)")
                mc.delete(savedCrypto[savedI])
                let rem = savedCrypto.remove(at: savedI)
                debugPrint("Removed \(rem.id)")
            }
            do {
                try mc.save()
            } catch {
                debugPrint("MC couldn't be saved")
            }
        }
        debugPrint("Deleted items")
        if let inList = cryptoSavedInfo.firstIndex(where: {$0.api_id == obj.api_id}) {
            cryptoSavedInfo.remove(at: inList)
        }
        
        /*
         fetchSaved()
         Task {
             await buildCryptoList()
         }
         */
        
    }
    
    public func toggleFavorite(obj: CryptoInfo) {
        if let mc = modelContext {
            
            let id = obj.api_id
            if let savedI = savedCrypto.firstIndex(where: { $0.id == id }) {
                debugPrint("Setting favorite \(savedCrypto[savedI].id) to \(!savedCrypto[savedI].favorite)")
                savedCrypto[savedI].favorite.toggle()
            }
            do {
                try mc.save()
            } catch {
                debugPrint("MC couldn't be saved")
            }
            
            if let inList = cryptoSavedInfo.firstIndex(where: {$0.api_id == obj.api_id}) {
                cryptoSavedInfo[inList].isFavorite.toggle()
            }
            debugPrint("Toggled favorites")
        }
    }
    
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
}
