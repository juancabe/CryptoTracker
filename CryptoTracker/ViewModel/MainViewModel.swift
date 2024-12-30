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
    
    // Keychain constants
    private let bundleName = "juancabe.CryptoTracker"
    private let keyValue = "apiKey"
    private let keychain: Keychain
    
    var isLoaded: Bool = false
    var justFavorites: Bool = false
    private var modelContext: ModelContext?
    
    private var refreshed: Date = Date()
    
    // State lists
    var savedCrypto: [SavedCrypto] = [SavedCrypto]()
    var allCryptoBasic: [BasicCrypto] = [BasicCrypto]()
    var cryptoSavedInfo: [CryptoInfo] = [CryptoInfo]()
    
    // UserDefaults needed for storing user's default currency
    private let defaults = UserDefaults.standard
    var currency: CurrencyInfo
    
    // Getter for currency
    func getCurrencyInfo() -> CurrencyInfo {
        return currency
    }
    // Setter for currency
    func setCurrencyInfo(_ currency: CurrencyInfo) {
        self.currency = currency
        fetchSaved()
        defaults.set(currency.currencyRepresentation, forKey: "currency")
        Task {
            await buildCryptoList()
        }
    }
    
    // Default init
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
    
    // Empty init, for previews
    init() {
        self.modelContext = nil
        self.keychain = Keychain(service: bundleName)
        self.currency = CurrencyInfo("usd")
    }
    
    // Function to refresh internal state of observed collections
    func refresh() async {
        do {
            try await Task.sleep(nanoseconds: 500_000_000) // Little delay 0.5s for UI flow
        } catch {
            debugPrint("Couldn't wait due to: \(error.localizedDescription)")
        }
        if refreshed < Date().addingTimeInterval(-10) { // Only refresh when 10 seconds after last refresh
            if allCryptoBasic.isEmpty { // Expensive API call
                await fetchAllCryptoBasic()
            }
            fetchSaved()
            await buildCryptoList(force: true)
            refreshed = Date()
        } else {
            debugPrint("Didn't refresh")
        }
    }
    
    func justFavoritesToggle() {
        justFavorites = !justFavorites
    }
    
    // Fetch saved crypto from SwiftData
    private func fetchSaved() {
        do{
            try savedCrypto = modelContext!.fetch(FetchDescriptor<SavedCrypto>())
        }
        catch {
            debugPrint("Error fetching saved crypto: \(error)")
        }
    }
    
    // Build CryptoInfo list from SavedCrypto list
    private func buildCryptoList(force: Bool = false) async {
        cryptoSavedInfo.removeAll()
        debugPrint("data.count: \(allCryptoBasic.count)")
        debugPrint("savedCrypto.count: \(savedCrypto.count)")
        for data in allCryptoBasic {
            
            if let index = savedCrypto.firstIndex(where: {
                $0.id == data.id
            }) {
                let isFavorite: Bool = savedCrypto[index].favorite
                if let info = await CryptoRetrieveService.getInstance().cryptoInfo(id: data.id, curr: currency, isSaved: true, isFavorite: isFavorite, apiKey: getAPIKey(), force: force) {
                    cryptoSavedInfo.append(info)
                } else {
                    debugPrint("[buildCryptoList] couldn't retrieve info for \(data.id)")
                }
            }
        }
    }
    
    // Fetch data from API
    private func fetchAllCryptoBasic() async {
        allCryptoBasic = await CryptoRetrieveService.getInstance().getAllCoinsBasic(apiKey: getAPIKey())
        await buildCryptoList()
    }
    
    // Add SavedCypto to SwiftData
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
    
    // Delte SavedCrypto from SwiftData
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
    }
    
    // Toggle favorite attribute from specific crypto
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
}
