//
//  InitialPriceAndTarget.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 3/1/25.
//

import SwiftUI

struct InitialPriceAndTarget: View {
    
    var target: Double
    var targetDecimals: Int
    var targetUnit: String
    var initialPrice: Double
    var currencySymbol: String
    
    var body: some View {
        VStack {
            Spacer()
                .font(.headline)
            Spacer()
            Text("\(target, specifier: "%.\(targetDecimals)f")\(targetUnit)")
                .font(.subheadline)
            Text("\(initialPrice, specifier: "%.4f") \(currencySymbol)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

#Preview {
    InitialPriceAndTarget(target: 429.2, targetDecimals: 3, targetUnit: "%", initialPrice: 142, currencySymbol: "$")
}
