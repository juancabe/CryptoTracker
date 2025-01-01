//
//  Alert.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 1/1/25.
//

import Foundation

protocol Alert {
    
    var currency: CurrencyInfo { get }
    var cryptoId: String { get }
    func expiresAt() -> Date
    
    // THESE METHODS WILL UPDATE INTERNAL STATE
    mutating func update(currentPrice: Double)
    mutating func isActive(currentPrice: Double) -> Bool
    mutating func isTriggered(currentPrice: Double) -> Bool
    
    
}
