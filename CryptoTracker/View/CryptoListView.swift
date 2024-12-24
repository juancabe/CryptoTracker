//
//  CryptoListView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//

import SwiftUI
import SwiftData

struct CryptoListView: View {
    @State public var vm: CryptoList

    var body: some View {
        NavigationSplitView {
            Text("Number of cryptos: \(vm.cryptoList.count)")
            List {
                ForEach(vm.cryptoList) { item in
                    NavigationLink {
                        Text("Item at \(item.name)")
                    } label: {
                        Text(item.symbol)
                    }
                }
                .onDelete(perform: vm.deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: vm.addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    init(modelContext: ModelContext?) {
        
        var vm : CryptoList
        
        if let mc = modelContext {
            vm = CryptoList(modelContext: mc)
            debugPrint("[CryptoListView] modelContext provided")
        } else {
            vm = CryptoList()
            debugPrint("[CryptoListView] NO modelContext provided")
        }
        
        _vm = State(initialValue: vm)
    }
}

#Preview {
    CryptoListView(modelContext: nil)
}
