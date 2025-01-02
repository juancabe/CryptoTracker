//
//  VolatilityAlertRow.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 2/1/25.
//

import SwiftUI

struct VolatilityAlertRow: View {
    
    @Binding var alert: Volatility
    
    var body: some View {
        HStack {
            Text("Alert on \(alert.cryptoId.uppercased())")
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            Text("\(alert.expiresAt())")
        }
    }
}
