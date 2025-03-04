//
//  AlertsViewModel.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 1/1/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class AlertsViewModel: ObservableObject {
    private var modelContext: ModelContext?

    var volatilityAlerts = [Volatility]()
    var priceAlerts = [PriceTarget]()

    var volPrices = [Volatility: Double?]()
    var tarPrices = [PriceTarget: Double?]()

    var isUpdating: Bool = false
    private var firstTime: Bool = true

    var ids = [String]()

    // Initialize with optional ModelContext and start update task
    init(_ mc: ModelContext? = nil) {
        modelContext = mc
        Task {
            await update()
        }
    }

    // Update alerts and prices
    func update() async {
        if isUpdating { return }

        if volatilityAlerts.isEmpty && priceAlerts.isEmpty && !firstTime {
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

    // Fetch saved alerts from the model context
    private func fetchSaved() {
        volatilityAlerts = try! modelContext!.fetch(FetchDescriptor<Volatility>())
        priceAlerts = try! modelContext!.fetch(FetchDescriptor<PriceTarget>())
        debugPrint("Fetched alerts: \(volatilityAlerts)")
    }

    // Update the list of saved crypto IDs
    func updateIds() {
        let savedCrypto = try! modelContext!.fetch(FetchDescriptor<SavedCrypto>())
        ids = savedCrypto.map(\.id)
    }

    // Update prices for all alerts
    func updatePrices() async {
        volPrices = [:]
        for alert in volatilityAlerts {
            let i = CryptoRetrieveService.getInstance()
            let price = await i.cryptoPrice(
                id: alert.cryptoId, curr: alert.currency, apiKey: i.getAPIKey())
            volPrices[alert] = price
        }

        tarPrices = [:]
        for alert in priceAlerts {
            let i = CryptoRetrieveService.getInstance()
            let price = await i.cryptoPrice(
                id: alert.cryptoId, curr: alert.currency, apiKey: i.getAPIKey())
            tarPrices[alert] = price
        }
    }

    // Update alerts with the latest prices
    func updateAlerts() {
        for alert in volatilityAlerts {
            if let currentPrice = volPrices[alert], let currentPrice = currentPrice {
                debugPrint("[update alert] alert initial price: \(alert.initialPrice)")
                debugPrint("[update alert] alert current price: \(currentPrice)")
                alert.update(currentPrice: currentPrice)
                debugPrint("[update alert] Already saved")
            } else {
                debugPrint("[update alert] no price found")
                continue
            }
        }

        for alert in priceAlerts {
            if let price = tarPrices[alert], let price {
                alert.update(currentPrice: price)
                debugPrint("[update alert] Already saved")
            } else {
                debugPrint("[update alert] no price found")
                continue
            }
        }

        try! modelContext!.save()
    }

    // Delete an alert and remove its notification
    func deleteAlert<T: Alert & Equatable & PersistentModel>(_ alert: T) {
        modelContext!.delete(alert)
        removeNotification(alertHash: alert.hashValue)
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

    // Add a new volatility alert
    func addVolatilityAlert(
        expiration: Date, volatilityThreshold: Double, cryptoId: String, curr: CurrencyInfo,
        notification: Bool
    ) async -> Bool {
        guard
            let currentPrice =
                await CryptoRetrieveService
                .getInstance().cryptoPrice(
                    id: cryptoId, curr: curr,
                    apiKey: CryptoRetrieveService.getInstance().getAPIKey())
        else {
            debugPrint("error fetching currentPrice, nil")
            return false
        }
        debugPrint("current price fetched")
        let alert: Volatility = Volatility(
            expiration: expiration, initialPrice: currentPrice,
            volatilityThreshold: volatilityThreshold, cryptoId: cryptoId, currency: curr)

        if volatilityAlerts.contains(where: { $0.id == alert.id }) { return false }
        modelContext!.insert(alert)

        try! modelContext!.save()
        if notification {
            addNotification(
                alertType: "Volatility alert",
                cryptoId: cryptoId.uppercased(),
                target: String(format: "%.2f%% volatility", volatilityThreshold),
                alertHash: alert.hashValue,
                alertExpiration: expiration)
        }
        volatilityAlerts.append(alert)
        return true
    }

    // Add a new price target alert
    func addPriceTargetAlert(
        expiration: Date, targetPrice: Double, cryptoId: String, currency: CurrencyInfo,
        notification: Bool
    ) async -> Bool {
        guard
            let currentPrice =
                await CryptoRetrieveService
                .getInstance().cryptoPrice(
                    id: cryptoId, curr: currency,
                    apiKey: CryptoRetrieveService.getInstance().getAPIKey())
        else { return false }
        let alert: PriceTarget = PriceTarget(
            expiration: expiration, initialPrice: currentPrice, targetPrice: targetPrice,
            cryptoId: cryptoId, currency: currency)
        if priceAlerts.contains(where: { $0.id == alert.id }) { return false }
        modelContext!.insert(alert)

        try! modelContext!.save()
        priceAlerts.append(alert)
        if notification {
            addNotification(
                alertType: "Price target alert",
                cryptoId: cryptoId.uppercased(),
                target: String(format: "%.2f %@", targetPrice, currency.currencySymbol),
                alertHash: alert.hashValue,
                alertExpiration: expiration)
        }
        return true
    }

    // Add a notification for an alert
    func addNotification(
        alertType: String, cryptoId: String, target: String, alertHash: Int, alertExpiration: Date
    ) {
        let identifier = String(alertHash)

        // Debug print the notification details
        debugPrint(
            "Notification will look like: \(alertType) expired for \(cryptoId), Target: \(target), Expiration: \(alertExpiration)"
        )

        NotificationsService.instance.addNotification(
            identifier: identifier,
            title: alertType + " expired for " + cryptoId,
            subtitle: "Check if the target " + target + " has been reached",
            when: alertExpiration)
    }

    // Remove a notification for an alert
    func removeNotification(alertHash: Int) {
        NotificationsService.instance.removeNotification(identifier: String(alertHash))
    }
}
