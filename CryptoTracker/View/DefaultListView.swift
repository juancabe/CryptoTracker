//
//  CryptoListView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import SwiftUI
import SwiftData

struct DefaultListView: View {
    @State public var vm: MainViewModel

    var body: some View {
        NavigationSplitView {
            Text("Number of cryptos: \(vm.cryptoSavedInfo.count)")
            List {
                ForEach(vm.cryptoSavedInfo) { item in
                    NavigationLink {
                        Text("Item at \(item.name)")
                    } label: {
                        CryptoListItemView(crypto: item)
                    }
                }
                .onDelete(perform: vm.deleteSaved)
            }
        } detail: {
            Text("Select an item")
        }
        .navigationTitle("Default List")
    }
    
    init(vm : MainViewModel) {
        _vm = State(initialValue: vm)
    }
}

#Preview {
    DefaultListView(vm: MainViewModel())
}
