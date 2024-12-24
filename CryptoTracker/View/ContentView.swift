//
//  ContentView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    private var modelContext: ModelContext? = nil

    var body: some View {
        TabView {
            CryptoListView(modelContext: modelContext)
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
        }
    }
    
    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
    }

    
}

#Preview {
    ContentView(modelContext: nil)
}
