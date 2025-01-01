//
//  Volatility.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 1/1/25.
//
import Foundation
import SwiftData


@Model
class Volatility : Alert {
    private var active: Bool
    private var triggered: Bool
    private var expiration: Date
    private var initiatedAt: Date
    private var initialPrice: Double
    private var volatilityThreshold: Double
    private var _cryptoId: String
    private var _currency: CurrencyInfo
    
    init(expiration: Date, initialPrice: Double, volatilityThreshold: Double, cryptoId: String, currency: CurrencyInfo) {
        self.active = true
        self.triggered = false
        self.expiration = expiration
        self.initiatedAt = Date()
        self.initialPrice = initialPrice
        self.volatilityThreshold = volatilityThreshold
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
    
    func update(currentPrice: Double) {
        // Update the triggered status based on the price comparison
        
        let upperBound = initialPrice * (1 + volatilityThreshold)
        let lowerBound = initialPrice * (1 - volatilityThreshold)
        
        triggered = currentPrice > upperBound || currentPrice < lowerBound
        active = Date() < expiration
    }
    
    func isActive(currentPrice: Double) -> Bool {
        update(currentPrice: currentPrice)
        return active
    }
    
    func isTriggered(currentPrice: Double) -> Bool {
        update(currentPrice: currentPrice)
        return triggered
    }
    
    func expiresAt() -> Date {
        return expiration
    }
}
