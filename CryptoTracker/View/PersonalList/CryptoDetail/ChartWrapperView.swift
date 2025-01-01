//
//  ChartWrapperView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 27/12/24.
//

import SwiftUI

// Wraps chart functionality by providing neccesary view model
struct ChartWrapperView: View {
    
    let vm: CryptoDetailViewModel
    let id: String
    let days: Int
    
    @State private var loaded: Bool = false
    @State private var mi: MarketInfo?
    
    init(vm: CryptoDetailViewModel, id: String, days: Int) {
        self.vm = vm
        self.id = id
        self.days = days
        self.mi = nil // mi = market info
    }
    
    var body: some View {
        NavigationView {
            if(mi != nil && loaded) { // Data loaded successfully
                MarketChartView(marketInfo: mi!)
            } else if loaded { // VM finished loading and no data provided -> error
                VStack {
                    Text("Error loading chart data")
                        .foregroundStyle(.red)
                        .font(.title)
                    Text("Maybe API key doesn't have enough privileges to access this data?")
                        .foregroundStyle(.red)
                        .opacity(0.7)
                        .padding([.horizontal], 30)
                }
            } else { // Show progress to user
                ProgressView()
            }
        }.onAppear {
            Task {
                mi = await vm.getMarketInfo(days: days, id: id)
                loaded = true
            }
        }
    }
    
}

