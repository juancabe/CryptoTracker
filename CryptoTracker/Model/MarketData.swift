//
//  MarketData.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 27/12/24.
//

import Foundation


struct MarketData: Codable {
    let prices: [[Double]]
    let market_caps: [[Double]]
    let total_volumes: [[Double]]
}
