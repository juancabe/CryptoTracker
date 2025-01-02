//
//  AlertRow.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 2/1/25.
//

import SwiftUI

struct AlertRow: View {
    
    @Binding var alert: Alert
    
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
