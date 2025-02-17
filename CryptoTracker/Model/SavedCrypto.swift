//
//  SavedCrypto.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import Foundation
import SwiftData

@Model
final class SavedCrypto {
    
    var id: String
    var favorite: Bool
    
    init (id: String) {
        self.id = id
        self.favorite = false
    }
}
