//
//  CryptoDetailViewModel.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 26/12/24.
//


import SwiftUI

class CryptoDetailViewModel: ObservableObject {
    @Published var cryptoInfo: CryptoInfo?
    @Published var isError: Bool = false
    @Published var isLoaded: Bool = false
    private let currency: CurrencyInfo
    private let vm: CryptoList

    init(id: String, currency: CurrencyInfo, vm: CryptoList) {
        self.currency = currency
        self.vm = vm
        Task {
            await fetchCryptoInfo(id: id)
        }
    }

    func fetchCryptoInfo(id: String) async {
        let response = await CryptoRetrieveService.getInstance().cryptoInfo(id: id, curr: currency)
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
    
    func addFavorite(id: String) {
        vm.addFavorite(id: id)
    }
}
