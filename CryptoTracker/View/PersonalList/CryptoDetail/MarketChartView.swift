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
    
    // Enum containing all supported chart types
    private enum ChartType {
        case price
        case volume
        case marketCap
    }
    
    @State private var selectedChart: ChartType = .price
    
    var body: some View {
        VStack {
            // Let user pick one of the charts
            Picker("Chart Type", selection: $selectedChart) {
                Text("Prices").tag(ChartType.price)
                Text("Volumes").tag(ChartType.volume)
                Text("Market Cap").tag(ChartType.marketCap)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedChart == ChartType.price {
                // Price chart
                let prices = marketInfo.prices.values
                let minPrice = prices.min() ?? 0
                let maxPrice = prices.max() ?? 0
                let yMin = minPrice * 0.7
                let yMax = maxPrice * 1.3
                
                Chart {
                    // Fill line chart with data
                    ForEach(marketInfo.prices.sorted(by: { $0.key < $1.key }), id: \.key) { date, price in
                        LineMark( // Add line mark
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
            } else if selectedChart == .volume {
                // Volume chart
                Chart {
                    // Fill bar chart with data
                    ForEach(marketInfo.totalVolumes.sorted(by: { $0.key < $1.key }), id: \.key) { date, volume in
                        BarMark( // Add bar mark
                            x: .value("Date", date),
                            y: .value("Volume", volume)
                        )
                        .foregroundStyle(.green.opacity(0.4))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else if selectedChart == .marketCap {
                // Market Cap chart
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
