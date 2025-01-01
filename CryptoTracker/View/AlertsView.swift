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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    AlertsView(AlertsViewModel())
}
