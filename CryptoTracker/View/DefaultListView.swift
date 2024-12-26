//
//  CryptoListView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import SwiftUI
import SwiftData

struct DefaultListView: View {
    @State public var vm: CryptoList

    var body: some View {
        NavigationSplitView {
            Text("Number of cryptos: \(vm.cryptoFavoritesInfo.count)")
            List {
                ForEach(vm.cryptoFavoritesInfo) { item in
                    NavigationLink {
                        Text("Item at \(item.name)")
                    } label: {
                        CryptoListItemView(crypto: item)
                    }
                }
                .onDelete(perform: vm.deleteFavorites)
            }
        } detail: {
            Text("Select an item")
        }
        .navigationTitle("Default List")
    }
    
    init(vm : CryptoList) {
        _vm = State(initialValue: vm)
    }
}

#Preview {
    DefaultListView(vm: CryptoList())
}
