//
//  BasicCrypto.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 30/12/24.
//


struct BasicCrypto : Hashable {
    let id: String
    let name: String
    let symbol: String
    
    init(id: String, name: String, symbol: String) {
        self.id = id
        self.name = name
        self.symbol = symbol
    }
}