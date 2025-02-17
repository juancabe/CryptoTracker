//
//  CryptoTrackerApp.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import SwiftData
import SwiftUI

@main
struct CryptoTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedCrypto.self,
            // Alerts
            PriceTarget.self,
            Volatility.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
}
