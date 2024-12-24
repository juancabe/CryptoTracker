//
//  Favorite.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import Foundation
import SwiftData

@Model
final class FavoriteCrypto {
    
    var addedAt: Date
    var name: String
    var symbol: String
    
    init(name: String, symbol: String) {
        self.name = name
        self.symbol = symbol
        self.addedAt = Date()
    }
}
