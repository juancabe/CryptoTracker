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
    
    var id: String
    
    init (id: String) {
        self.id = id
    }
}
