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
    private var mvm: MainViewModel

    @State private var selectedTab = 1
    var body: some View {
        TabView(selection: $selectedTab) {
            AlertsView(modelContext)
                .tabItem {
                    Label("Alerts", systemImage: "bell")
                }
                .tag(0)

            PersonalListView(vm: mvm)
                .tabItem {
                    Label("Your cryptos", systemImage: "star")
                }
                .tag(1)

            SettingsView(vm: mvm)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
    
    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
        if let modelContext {
            self.mvm = MainViewModel(modelContext: modelContext)
        } else {
            self.mvm = MainViewModel()
        }
    }

    
}

#Preview {
    ContentView(modelContext: nil)
}
