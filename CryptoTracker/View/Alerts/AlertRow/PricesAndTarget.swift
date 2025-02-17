//
//  PricesAndTarget.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 3/1/25.
//

import SwiftUI

struct PricesAndTarget: View {
    
    var target: Double
    var targetDecimals: Int
    var targetUnit: String
    var initialPrice: Double
    var currencySymbol: String
    var currentPrice: Double
    
    @State private var isAnimating = false

    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "record.circle")
                    .font(.system(size: isAnimating ? 20 : 18)) // Change size dynamically
                    .foregroundStyle(.red)
                    .animation(.easeInOut(duration: 0.6), value: isAnimating) // Smooth transition
                    .frame(width: 20, height: 20)
                    .onAppear {
                        startAnimation()
                    }
                Text("\(currentPrice, specifier: "%.2f") \(currencySymbol)")
                    .font(.subheadline)
                Spacer()
                
            }
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "dot.scope")
                    .font(.subheadline) // Change size dynamically
                    .foregroundStyle(.gray)
                Text("\(target, specifier: "%.\(targetDecimals)f")\(targetUnit)")
                    .font(.subheadline)
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "backward.fill")
                    .font(.subheadline) // Change size dynamically
                    .foregroundStyle(.blue)
                Text("\(initialPrice, specifier: "%.2f") \(currencySymbol)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            Spacer()
        }
    }
    
    private func startAnimation() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            isAnimating.toggle()
        }
        timer.fire() // Start immediately
    }
}

#Preview {
    PricesAndTarget(target: 429.2, targetDecimals: 3, targetUnit: "%", initialPrice: 142, currencySymbol: "$", currentPrice: 456.2)
        .frame(width: 200, height: 50)
}
