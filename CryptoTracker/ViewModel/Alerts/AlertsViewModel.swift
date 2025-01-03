//
//  AlertsViewModel.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 1/1/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class AlertsViewModel : ObservableObject{
    private var modelContext: ModelContext?
    
    
    var volatilityAlerts = [Volatility]()
    var priceAlerts = [PriceTarget]()
    
    var volPrices = [Volatility: Double?]()
    var tarPrices = [PriceTarget: Double?]()
    
    
    var isUpdating: Bool = false
    private var firstTime: Bool = true
    
    
    var ids = [String]()
    
    init (_ mc: ModelContext? = nil) {
        modelContext = mc
        Task {
            await update()
        }
    }
    
    func update() async {
        if isUpdating
        { return }
        
        if volatilityAlerts.isEmpty &&
            priceAlerts.isEmpty &&
            !firstTime
        {
            isUpdating = true
            try! await Task.sleep(nanoseconds: 300_000_000)
            updateIds()
            debugPrint("IDs updated")
            isUpdating = false
            return
        }
        
        
        isUpdating = true
        try! await Task.sleep(nanoseconds: 1_000_000_000)
        
        updateIds()
        debugPrint("IDs updated")
        fetchSaved()
        debugPrint("Saved fetched")
        await updatePrices()
        debugPrint("Prices updated")
        updateAlerts()
        debugPrint("Alerts updated")
        isUpdating = false
        
        firstTime = false
    }
    
    private func fetchSaved() {
        volatilityAlerts = try! modelContext!.fetch(FetchDescriptor<Volatility>())
        priceAlerts = try! modelContext!.fetch(FetchDescriptor<PriceTarget>())
        debugPrint("Fetched alerts: \(volatilityAlerts)")
    }
    
    func updateIds() {
        let savedCrypto = try! modelContext!.fetch(FetchDescriptor<SavedCrypto>())
        ids = savedCrypto.map(\.id)
    }
    
    func updatePrices() async {
        volPrices = [:]
        for alert in volatilityAlerts {
            let i = CryptoRetrieveService.getInstance()
            let price = await i.cryptoPrice(id: alert.cryptoId, curr: alert.currency, apiKey: i.getAPIKey())
            volPrices[alert] = price
        }
        
        tarPrices = [:]
        for alert in priceAlerts {
            let i = CryptoRetrieveService.getInstance()
            let price = await i.cryptoPrice(id: alert.cryptoId, curr: alert.currency, apiKey: i.getAPIKey())
            tarPrices[alert] = price
        }
    }
    
    func updateAlerts() {
        
        for alert in volatilityAlerts {
            if let currentPrice = volPrices[alert], let currentPrice = currentPrice {
                debugPrint("[update alert] alert inital price: \(alert.initialPrice)")
                debugPrint("[update alert] alert current price: \(currentPrice)")
                alert.update(currentPrice: currentPrice)
                debugPrint("[update alert] Alredy saved")
            } else {
                debugPrint("[update alert] no price found")
                continue
            }
        }
        
        for alert in priceAlerts {
            if let price = tarPrices[alert], let price {
                alert.update(currentPrice: price)
                debugPrint("[update alert] Alredy saved")
            } else {
                debugPrint("[update alert] no price found")
                continue
            }
        }
        
        try! modelContext!.save()
    }
    
    func deleteAlert<T: Alert & Equatable & PersistentModel>(_ alert: T) {
        modelContext!.delete(alert)
        if T.self == Volatility.self {
            volatilityAlerts.removeAll { $0 == alert as! Volatility }
        } else if T.self == PriceTarget.self {
            priceAlerts.removeAll { $0 == alert as! PriceTarget }
        } else {
            debugPrint("Unknown alert type")
            exit(EXIT_FAILURE)
        }
        try! modelContext?.save()
        
    }
    
    func addVolatilityAlert(expiration: Date, volatilityThreshold: Double, cryptoId: String, curr: CurrencyInfo)
    async -> Bool
    {
        guard let currentPrice = await CryptoRetrieveService
            .getInstance().cryptoPrice(id: cryptoId, curr: curr,
                                       apiKey: CryptoRetrieveService.getInstance().getAPIKey())
        else {
            debugPrint("error fetching currentPrice, nil")
            return false
        }
        debugPrint("current price fetched")
        let alert: Volatility = Volatility(expiration: expiration, initialPrice: currentPrice, volatilityThreshold: volatilityThreshold, cryptoId: cryptoId, currency: curr)
        
        if volatilityAlerts.contains(where: { $0.id == alert.id }) { return false }
        modelContext!.insert(alert)
        
        try! modelContext!.save()
        volatilityAlerts.append(alert)
        return true
        
    }
    
    func addPriceTargetAlert(expiration: Date, targetPrice: Double, cryptoId: String, currency: CurrencyInfo)
    async -> Bool
    {
        guard let currentPrice = await CryptoRetrieveService
            .getInstance().cryptoPrice(id: cryptoId, curr: currency,
                                       apiKey: CryptoRetrieveService.getInstance().getAPIKey())
        else { return false }
        let alert: PriceTarget = PriceTarget(expiration: expiration, initialPrice: currentPrice, targetPrice: targetPrice, cryptoId: cryptoId, currency: currency)
        if priceAlerts.contains(where: { $0.id == alert.id }) { return false }
        modelContext!.insert(alert)
        
        try! modelContext!.save()
        priceAlerts.append(alert)
        return true
    }
}
