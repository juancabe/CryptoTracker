//
//  AlertList.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 3/1/25.
//

import Foundation
import SwiftUI

struct AlertList: View {
    
    @ObservedObject var vm: AlertsViewModel
    var pt: Bool
    var v: Bool
    
    init<T: Alert & Identifiable>(list: [T], vm: AlertsViewModel) {
        self.vm = vm
        
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
            List {
                ForEach($vm.volatilityAlerts) { $a in
                    if let price = vm.volPrices[a], let price {
                        AlertRow(alert: a, price: price, targetDecimals: 2)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { // Swipe left to delete favorite crypto
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
            List {
                ForEach($vm.priceAlerts) { $a in
                    if let price = vm.tarPrices[a], let price {
                        AlertRow(alert: a, price: price, targetDecimals: 4)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { // Swipe left to delete favorite crypto
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
