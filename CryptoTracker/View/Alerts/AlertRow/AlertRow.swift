//
//  AlertRow.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 2/1/25.
//
import SwiftUI

struct AlertRow: View {
    
    var alert: any Alert
    var price: Double
    private var targetDecimals: Int
    private var target: Double
    private var targetUnit: String
    
    init(alert: any Alert, price: Double, targetDecimals: Int) {
        self.alert = alert
        self.price = price
        self.targetDecimals = targetDecimals
        switch alert {
        case let alert as Volatility:
            target = alert.getVolatilityThreshold()
            targetUnit = "%"
            
        case let alert as PriceTarget:
            target = alert.getTargetPrice()
            targetUnit = alert.currency.currencySymbol
            
        default:
            debugPrint("Unknown alert type")
            exit(EXIT_FAILURE)
        }
    }
    
    var body: some View {
        
        HStack {
            AlertStateImage(isActive: alert.isActive(currentPrice: price), isTriggered: alert.isTriggered(currentPrice: price))
            NameAndDate(id: alert.cryptoId, expirationDate: alert.expiresAt())
            Spacer()
            PricesAndTarget(target: target, targetDecimals: targetDecimals, targetUnit: targetUnit, initialPrice: alert.initialPrice, currencySymbol: alert.currency.currencySymbol, currentPrice: price)
        }
    }
}
