//
//  CurrencyInfo.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 27/12/24.
//


struct CurrencyInfo : Hashable {
    
    static let symbols: [String: String] = [ // Dict of well known currencies
        "usd": "$",
        "eur": "€",
        "gbp": "£",
        "jpy": "¥",
    ]
    
    let currencyRepresentation: String // Currency representation == usd, eur, gbp, jpy -> API needs those
    let currencySymbol: String // Symbol for user
    
    init(_ currencyRepresentation: String) {
        self.currencyRepresentation = currencyRepresentation
        if let currencySymbol = CurrencyInfo.symbols[currencyRepresentation] {
            self.currencySymbol = currencySymbol
        } else {
            debugPrint("representation not found")
            self.currencySymbol = currencyRepresentation.uppercased()
        }
    }
    
    init() {
        self.currencyRepresentation = "currencyRepresentation"
        self.currencySymbol = "currencySymbol"
    }
}
