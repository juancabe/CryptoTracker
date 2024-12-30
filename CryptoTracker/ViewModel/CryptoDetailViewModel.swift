//
//  CryptoDetailViewModel.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 26/12/24.
//


import SwiftUI

// Specific ViewModel for CryptoDetail abstraction
class CryptoDetailViewModel: ObservableObject {
    @Published var cryptoInfo: CryptoInfo? = nil
    @Published var isError: Bool = false
    @Published var isLoaded: Bool = false
    @Published var isFavorite: Bool
    private let currency: CurrencyInfo
    private let vm: MainViewModel

    init(id: String, currency: CurrencyInfo, vm: MainViewModel, isFavorite: Bool) {
        self.currency = currency
        self.vm = vm
        self.isFavorite = isFavorite
        Task {
            await fetchCryptoInfo(id: id)
        }
    }
    
    init(info: CryptoInfo, vm: MainViewModel) {
        self.cryptoInfo = info
        self.vm = vm
        self.currency = vm.currency
        self.isLoaded = true
        self.isFavorite = info.isFavorite
    }
    
    // Fetches cryptoInfo from RetrieveService
    func fetchCryptoInfo(id: String) async {
        
        if(id.isEmpty) {
            DispatchQueue.main.async {
                self.cryptoInfo = nil
                self.isLoaded = false
                self.isError = true
                return
            }
        }
        
        let response = await CryptoRetrieveService.getInstance().cryptoInfo(id: id, curr: currency, isFavorite: isFavorite, apiKey: vm.getAPIKey())
        DispatchQueue.main.async {
            if let response {
                self.cryptoInfo = response
                self.isLoaded = true
            } else {
                self.isError = true
                self.isLoaded = true
            }
        }
    }
    
    // Fetches marketInfo for the selected days
    func getMarketInfo(days: Int, id: String) async -> MarketInfo? {
        let data = await CryptoRetrieveService.getInstance().marketData(id: id, curr: currency, days: days, apiKey: vm.getAPIKey())
        if let data {
            let info = MarketInfo(from: data)
            return info
        }
        return nil
    }
    
    // Add saved crypto, will only be called when crypto wasn't alredy saved
    func addSaved(id: String) {
        vm.addSaved(id: id)
    }
}
