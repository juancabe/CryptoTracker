//
//  PersonalListView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 24/12/24.
//

import SwiftUI
import SwiftData

struct PersonalListView: View {
    @State public var vm: CryptoList

    var body: some View {
        NavigationView {
            ZStack {
                
                
                VStack {
                    NavigationSplitView {
                        if(vm.favorites.isEmpty) {
                            Text("No favorites").font(.headline).padding(.top, 300.0)
                            Text("Try adding some favorites").font(.subheadline).foregroundColor(.secondary)
                        }
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
                    .navigationTitle("Personal List")
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink {
                            AddFavoriteView(vm: vm)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                
                        }
                        .padding(.trailing, 40.0)
                        .background(.clear)
                    }
                }
                
                
            }
            
        }
        .animation(.default)
        
    }
    
    init(vm : CryptoList) {
              
        _vm = State(initialValue: vm)
    }
}

#Preview {
    PersonalListView(vm: CryptoList())
}
