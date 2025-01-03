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
                        // To keep list syncronized with vm.cryptoSavedInfo when adding item
                        Text("\($vm.cryptoSavedInfo.count)").opacity(0.0)
                        if(vm.savedCrypto.isEmpty) { // User hasn't saved any crypto yet
                            Text("No saved crypto").font(.headline).padding(.top, 300.0)
                            Text("Try saving some crypto").font(.subheadline).foregroundColor(.secondary)
                        }
                        // List of items stored on vm.cryptoSavedInfo
                        
                        if(!vm.isLoaded) {
                            Spacer()
                            ProgressView()
                            Spacer()
                        } else {
                            List {
                                ForEach($vm.cryptoSavedInfo) { $item in
                                    if(!vm.justFavorites || item.isFavorite) {
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
                                            Button { // Swipe right to add a favorite
                                                withAnimation {
                                                    vm.toggleFavorite(obj: item)
                                                }
                                            } label: {
                                                Label("Custom", systemImage: "star")
                                                    .foregroundStyle(.yellow)
                                            }
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) { // Swipe left to delete favorite crypto
                                                withAnimation {
                                                    vm.deleteSaved(obj: item)
                                                }
                                                
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                    } detail: {
                        Text("Select an item")
                    }
                }
                .navigationTitle("Personal List")
                
                // Overlapping buttons
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
                                .rotationEffect(!vm.isLoaded ? .degrees(360) : .degrees(0))
                                .animation(!vm.isLoaded ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: !vm.isLoaded)
                        }
                        .background(.clear)
                        .disabled(!vm.isLoaded)
                    }
                    .padding([.leading], 20)
                    Spacer()
                    VStack {
                        Spacer()
                        Button { // Button for displaying favorites only
                            vm.justFavoritesToggle()
                        } label: {
                            if (vm.justFavorites) {
                                Image(systemName: "star.circle.fill")
                                    .font(.system(size: 50))
                            } else {
                                Image(systemName: "star.circle")
                                    .font(.system(size: 50))
                            }
                        }
                        .background(.clear)
                        NavigationLink { // NavLink for adding saved crypto
                            AddSavedView(vm: vm)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                        }
                        .background(.clear)
                    }
                    .padding([.trailing], 20)
                }
            }
        }
    }
    
    private func startSpinningAndUpdate() async {
        if vm.isLoaded {
            await vm.refresh()
        }
    }
    
    init(vm : MainViewModel) {
              
        _vm = State(initialValue: vm)
    }
}

#Preview {
    PersonalListView(vm: MainViewModel())
}
