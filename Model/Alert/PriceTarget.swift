//
//  PriceTarget.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 1/1/25.
//

import Foundation

struct PriceTarget: Alert {
    
    private var active: Bool
    private var triggered: Bool
    private var expiration: Date
    private var initiatedAt: Date
    private var initialPrice: Double
    private var targetPrice: Double
    private var _cryptoId: String
    private var _currency: CurrencyInfo
    
    init(expiration: Date, initialPrice: Double, targetPrice: Double, cryptoId: String, currency: CurrencyInfo) {
        self.active = true
        self.triggered = false
        self.expiration = expiration
        self.initiatedAt = Date()
        self.initialPrice = initialPrice
        self.targetPrice = targetPrice
        self._cryptoId = cryptoId
        self._currency = currency
    }
    
    var currency: CurrencyInfo {
        get {
            return _currency
        }
    }
    
    var cryptoId: String {
        get {
            return _cryptoId
        }
    }
    
    mutating func update(currentPrice: Double) {
        // Update the triggered status based on the price comparison
        triggered = (initialPrice > targetPrice) ? (currentPrice < targetPrice) : (currentPrice > targetPrice)
        active = Date() < expiration
    }
    
    mutating func isActive(currentPrice: Double) -> Bool {
        update(currentPrice: currentPrice)
        return active
    }
    
    mutating func isTriggered(currentPrice: Double) -> Bool {
        update(currentPrice: currentPrice)
        return triggered
    }
    
    func expiresAt() -> Date {
        return expiration
    }
    
    
}
