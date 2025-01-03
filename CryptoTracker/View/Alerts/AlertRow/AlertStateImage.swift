//
//  AlertStateImage.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 3/1/25.
//

import SwiftUI

struct AlertStateImage: View {
    
    var isActive: Bool
    var isTriggered: Bool
    
    var body: some View {
        VStack {
            Spacer()
            if isActive {
                Image(systemName: "smallcircle.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.system(size: 20))
            } else if isTriggered {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 20))
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.system(size: 20))
            }
            Spacer()
        }
    }
}
