//
//  MarketInfo.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 27/12/24.
//

import Foundation

struct MarketInfo {
    var prices: [Date: Double]
    var marketCaps: [Date: Double]
    var totalVolumes: [Date: Double]
    
    init(from data: MarketData) {
        self.prices = Dictionary(uniqueKeysWithValues: data.prices.map {
            (Date(timeIntervalSince1970: $0[0] / 1000.0), $0[1])
        })
        self.marketCaps = Dictionary(uniqueKeysWithValues: data.market_caps.map {
            (Date(timeIntervalSince1970: $0[0] / 1000.0), $0[1])
        })
        self.totalVolumes = Dictionary(uniqueKeysWithValues: data.total_volumes.map {
            (Date(timeIntervalSince1970: $0[0] / 1000.0), $0[1])
        })
    }
}
