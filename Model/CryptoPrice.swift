//
//  CryptoPrice.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 1/1/25.
//

struct CryptoPrice: Codable {
    let crypto: Crypto
    struct Crypto: Codable {
        let price: Double
    }
}
