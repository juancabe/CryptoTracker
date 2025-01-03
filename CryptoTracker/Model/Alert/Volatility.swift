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
    private var _initialPrice: Double
    private var volatilityThreshold: Double
    private var _cryptoId: String
    private var _currency: CurrencyInfo
    
    init(expiration: Date, initialPrice: Double, volatilityThreshold: Double, cryptoId: String, currency: CurrencyInfo) {
        self.active = true
        self.triggered = false
        self.expiration = expiration
        self.initiatedAt = Date()
        self._initialPrice = initialPrice
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
    
    var initialPrice: Double {
        get {
            return _initialPrice
        }
    }
    
    func getInitialPrice() -> Double {
        return _initialPrice
    }
    
    func getVolatilityThreshold() -> Double {
        return volatilityThreshold
    }
    
    func update(currentPrice: Double) {
        // Update the triggered status based on the price comparison
        if  triggered || !active { return }
        if Date() > expiration {
            active = false
            triggered = false
            return
        }
        
        let upperBound = _initialPrice * (1 + volatilityThreshold/100)
        let lowerBound = _initialPrice * (1 - volatilityThreshold/100)
        
        // If it's triggered, it cannot be active
        triggered = currentPrice > upperBound || currentPrice < lowerBound
        active = !triggered
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
