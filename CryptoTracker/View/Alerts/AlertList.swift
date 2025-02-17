//
//  AlertList.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 3/1/25.
//

import Foundation
import SwiftUI

// View to display a list of alerts
struct AlertList: View {

    @ObservedObject var vm: AlertsViewModel
    var pt: Bool
    var v: Bool

    // Initialize with a list of alerts and a view model
    init<T: Alert & Identifiable>(list: [T], vm: AlertsViewModel) {
        self.vm = vm

        // Determine the type of alert
        switch T.self {
        case is PriceTarget.Type:
            pt = true
            v = false
        case is Volatility.Type:
            v = true
            pt = false
        default:
            debugPrint("[AlertList init] Type unknown")
            exit(EXIT_FAILURE)
        }
    }

    var body: some View {
        if v {
            // Display list of volatility alerts
            List {
                ForEach($vm.volatilityAlerts) { $a in
                    if let price = vm.volPrices[a], let price {
                        AlertRow(alert: a, price: price, targetDecimals: 2)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {  // Swipe left to delete alert
                                    withAnimation {
                                        vm.deleteAlert(a)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        } else if pt {
            // Display list of price target alerts
            List {
                ForEach($vm.priceAlerts) { $a in
                    if let price = vm.tarPrices[a], let price {
                        AlertRow(alert: a, price: price, targetDecimals: 4)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {  // Swipe left to delete alert
                                    withAnimation {
                                        vm.deleteAlert(a)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        } else {
            exit(EXIT_FAILURE)
        }

    }
}
