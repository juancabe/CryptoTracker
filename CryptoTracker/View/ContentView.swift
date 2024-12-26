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
    private var cryptoListVm: CryptoList

    var body: some View {
        TabView {
            DefaultListView(vm: cryptoListVm)
                .tabItem {
                    Label("All Cryptos", systemImage: "list.bullet")
                }
            PersonalListView(vm: cryptoListVm)
                .tabItem {
                    Label("Your cryptos", systemImage: "star")
                }
        }
    }
    
    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
        if let modelContext {
            self.cryptoListVm = CryptoList(modelContext: modelContext)
        } else {
            self.cryptoListVm = CryptoList()
        }
    }

    
}

#Preview {
    ContentView(modelContext: nil)
}
