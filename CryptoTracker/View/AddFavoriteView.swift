//
//  AddFavoriteView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 24/12/24.
//

import SwiftUI

struct AddFavoriteView: View {
    
    @ObservedObject var vm: CryptoList
    @State private var searchText = ""
    private let currency: CurrencyInfo
    
    
    init(vm: CryptoList) {
        self.vm = vm
        currency = vm.currency
    }

    var body: some View {
        NavigationStack {
            Text("\(vm.allCryptoBasic.count) cryptos available")
            
            if(searchText != "") {
                Text("Searching for \(searchText)")
                List {
                    ForEach(vm.allCryptoBasic, id: \.self) { item in
                        if(item.symbol.lowercased() == searchText.lowercased() || item.name.lowercased() == searchText.lowercased()) {
                            NavigationLink {
                                CryptoDetailView(id: item.id, curr: currency, vm: vm, isFav: false)
                                
                            } label: {
                                Text(item.name)
                            }
                        }
                    }
                }
                .navigationTitle("Add a favorite")
            }
            
        }
        .searchable(text: $searchText)
        .animation(.default)
    }
}
    

#Preview {
    AddFavoriteView(vm: CryptoList())
}
