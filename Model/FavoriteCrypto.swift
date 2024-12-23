//
//  Favorite.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import Foundation
import SwiftData

@Model
final class Favorite : Cryptocurrency {
    
    var addedAt: Date
    
    override init(name: String, symbol: String)
    {
        addedAt = Date()
        super.init(name: name, symbol: symbol)
    }
}
