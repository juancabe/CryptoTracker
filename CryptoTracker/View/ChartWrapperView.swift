//
//  ChartWrapperView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 27/12/24.
//

import SwiftUI

struct ChartWrapperView: View {
    
    let vm: CryptoDetailViewModel
    let id: String
    let days: Int
    
    @State private var mi: MarketInfo?
    
    init(vm: CryptoDetailViewModel, id: String, days: Int) {
        self.vm = vm
        self.id = id
        self.days = days
        self.mi = nil
    }
    
    var body: some View {
        NavigationView {
            if(mi != nil) {
                MarketChartView(marketInfo: mi!)
            } else {
                ProgressView()
            }
        }.onAppear {
            Task {
                mi = await vm.getMarketInfo(days: days, id: id)
            }
        }
    }
    
}

