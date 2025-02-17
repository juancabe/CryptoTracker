//
//  AlertsView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 1/1/25.
//

import SwiftUI
import SwiftData

struct AlertsView: View {
    
    @ObservedObject private var vm: AlertsViewModel
    
    init(_ mc: ModelContext? = nil) {
        if let mc {
            self.vm = .init(mc)
        } else {
            self.vm = .init()
        }
    }
    var body: some View {
        NavigationView {
            ZStack {
                TabView {
                    HStack {
                        if vm.isUpdating {
                            ProgressView()
                        } else if(vm.volatilityAlerts.isEmpty) {
                            Text("No alerts")
                        } else {
                            AlertList(list: vm.volatilityAlerts, vm: vm)
                        }
                    }
                    .tabItem {
                        Label("Volatility", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    
                    HStack {
                        if vm.isUpdating {
                            ProgressView()
                        } else if(vm.priceAlerts.isEmpty) {
                            Text("No alerts")
                        } else {
                            AlertList(list: vm.priceAlerts, vm: vm)
                        }
                    }
                    .tabItem {
                        Label("Price Targets", systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                    }
                }
                .onAppear {
                    // Update available ids when Alerts tab is selected
                    // because new cryptos may have been added
                    Task {
                        await startSpinningAndUpdate()
                    }
                }
                .padding([.top], 30)
                
                // Overlapped button
                HStack {
                    VStack { // Button for refreshing
                        Spacer()
                        Button {
                            Task {
                                await startSpinningAndUpdate()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 50))
                                .rotationEffect(vm.isUpdating ? .degrees(360) : .degrees(0))
                                .animation(vm.isUpdating ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: vm.isUpdating)
                        }
                        .background(.clear)
                        .disabled(vm.isUpdating)
                    }
                    .padding([.bottom], 40)
                    .padding([.leading], 20)
                    
                    Spacer()
                    
                    VStack { // Button for adding new alert
                        Spacer()
                        NavigationLink { // NavLink for adding alert
                            AddAlertView(vm: vm)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                        }
                        .background(.clear)
                    }
                    .padding([.bottom], 40)
                    .padding([.trailing], 20)
                }
            }
            .navigationTitle("Alerts")
        }
    }
    
    /// Starts spinning animation and performs the update asynchronously.
    private func startSpinningAndUpdate() async {
        if !vm.isUpdating {
            await vm.update()
        }
    }
}

#Preview {
    AlertsView()
}
