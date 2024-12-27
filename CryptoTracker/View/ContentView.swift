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
    private var vm: MainViewModel

    var body: some View {
        TabView {
            /*
            DefaultListView(vm: cryptoListVm)
                .tabItem {
                    Label("All Cryptos", systemImage: "list.bullet")
                }
             */
            PersonalListView(vm: vm)
                .tabItem {
                    Label("Your cryptos", systemImage: "star")
                }
            SettingsView(vm: vm)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
    
    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
        if let modelContext {
            self.vm = MainViewModel(modelContext: modelContext)
        } else {
            self.vm = MainViewModel()
        }
    }

    
}

#Preview {
    ContentView(modelContext: nil)
}
