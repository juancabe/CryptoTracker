//
//  PersonalListView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 24/12/24.
//

import SwiftUI
import SwiftData

struct PersonalListView: View {
    @State public var vm: MainViewModel

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    NavigationSplitView {
                        if(vm.savedCrypto.isEmpty) {
                            Text("No saved crypto").font(.headline).padding(.top, 300.0)
                            Text("Try saving some crypto").font(.subheadline).foregroundColor(.secondary)
                        }
                        // To keep list syncronized with vm.cryptoSavedInfo when adding item
                        Text("\($vm.cryptoSavedInfo.count)").opacity(0.0)
                        
                        // List of items stored on vm.cryptoSavedInfo
                        List {
                            ForEach($vm.cryptoSavedInfo) { $item in
                                NavigationLink {
                                    CryptoDetailView(info: item, vm: vm)
                                } label: {
                                    ZStack {
                                        CryptoListItemView(crypto: item)
                                        if(item.isFavorite) {
                                            HStack {
                                                VStack {
                                                    Image(systemName: "star.fill")
                                                        .foregroundStyle(.yellow)
                                                    Spacer()
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                    
                                }
                                .swipeActions (edge: .leading) {
                                    Button {
                                        withAnimation {
                                            vm.toggleFavorite(obj: item)
                                        }
                                    } label: {
                                        Label("Custom", systemImage: "star")
                                            .foregroundStyle(.yellow)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            vm.deleteSaved(obj: item)
                                        }
                                        
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    
                    } detail: {
                        Text("Select an item")
                    }
                    
                }
                .navigationTitle("Personal List")
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink {
                            AddSavedView(vm: vm)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                        }
                        .padding(.trailing, 20.0)
                        .background(.clear)
                    }
                }
            }
        }
    }
    
    init(vm : MainViewModel) {
              
        _vm = State(initialValue: vm)
    }
}

#Preview {
    PersonalListView(vm: MainViewModel())
}
