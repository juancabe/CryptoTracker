//
//  AlertsViewModel.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 1/1/25.
//

import Foundation
import SwiftData

@Observable
class AlertsViewModel {
    private var modelContext: ModelContext?
    
    init (_ mc: ModelContext? = nil) {
        modelContext = mc
    }
}
