//
//  AddSavedView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 24/12/24.
//

import SwiftUI

struct AddSavedView: View {
    
    @ObservedObject var vm: MainViewModel
    @State private var searchText = ""
    private let currency: CurrencyInfo
    
    
    init(vm: MainViewModel) {
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
                                CryptoDetailView(id: item.id, curr: currency, vm: vm, isSaved: false, isFavorite: false)
                                
                            } label: {
                                Text(item.name)
                            }
                        }
                    }
                }
                .navigationTitle("Add a saved crypto")
            }
            
        }
        .searchable(text: $searchText)
    }
}
    

#Preview {
    AddSavedView(vm: MainViewModel())
}
