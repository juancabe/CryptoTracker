//
//  MarketChartView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 27/12/24.
//


import SwiftUI
import Charts

struct MarketChartView: View {
    let marketInfo: MarketInfo
    @State private var selectedChart = 0
    
    var body: some View {
        VStack {
            Picker("Chart Type", selection: $selectedChart) {
                Text("Prices").tag(0)
                Text("Volumes").tag(1)
                Text("Market Cap").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedChart == 0 {
                let prices = marketInfo.prices.values
                let minPrice = prices.min() ?? 0
                let maxPrice = prices.max() ?? 0
                let yMin = minPrice * 0.7
                let yMax = maxPrice * 1.3
                
                Chart {
                    ForEach(marketInfo.prices.sorted(by: { $0.key < $1.key }), id: \.key) { date, price in
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Price", price)
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .chartYScale(domain: yMin...yMax)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else if selectedChart == 1 {
                Chart {
                    ForEach(marketInfo.totalVolumes.sorted(by: { $0.key < $1.key }), id: \.key) { date, volume in
                        BarMark(
                            x: .value("Date", date),
                            y: .value("Volume", volume)
                        )
                        .foregroundStyle(.green.opacity(0.4))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else if selectedChart == 2 {
                let marketCaps = marketInfo.marketCaps.values
                let minCap = marketCaps.min() ?? 0
                let maxCap = marketCaps.max() ?? 0
                let yMin = minCap * 0.7
                let yMax = maxCap * 1.3
                
                Chart {
                    ForEach(marketInfo.marketCaps.sorted(by: { $0.key < $1.key }), id: \.key) { date, cap in
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Market Cap", cap)
                        )
                        .foregroundStyle(.purple)
                    }
                }
                .chartYScale(domain: yMin...yMax)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
    }
}
