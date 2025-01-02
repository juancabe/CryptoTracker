//
//  AlertsView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 1/1/25.
//

import SwiftUI

struct AlertsView: View {
    
    @State var vm: AlertsViewModel
    
    init(_ vm: AlertsViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.alerts) { alert in
                    AlertRow(alert: alert)
                }
            }
            .navigationTitle("Alerts")
        }
    }
}

#Preview {
    AlertsView(AlertsViewModel())
}
