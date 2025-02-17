//
//  Alert.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 1/1/25.
//

import Foundation
import SwiftData

protocol Alert : PersistentModel {
    
    var currency: CurrencyInfo { get }
    var initialPrice: Double { get }
    var cryptoId: String { get }
    func expiresAt() -> Date
    
    // THESE METHODS WILL UPDATE INTERNAL STATE
    func update(currentPrice: Double)
    func isActive(currentPrice: Double) -> Bool
    func isTriggered(currentPrice: Double) -> Bool
    
    
}
