//
//  AlertTypes.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 2/1/25.
//


enum AlertTypes: String, CaseIterable, Identifiable {
    case VolatilityAlert = "Volatility"
    case PriceTargetAlert = "Price Target"
    
    var id: String { self.rawValue }
}
