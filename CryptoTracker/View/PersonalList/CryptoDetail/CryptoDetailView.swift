//
//  CryptoDetailView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 26/12/24.
//

import SwiftUI
import Foundation

struct Row: View {
    
    var fieldName: String
    var value: String
    
    var body: some View {
        HStack {
            
            HStack {
                Text(fieldName).opacity(0.4)
            }
            Spacer()
            HStack {
                Text("\(value)")
            }
        }.padding(.horizontal, 10)
    }
}

struct CryptoDetailView: View {
    @StateObject private var viewModel: CryptoDetailViewModel
    @State var isSaved: Bool
    @State var dateFrom: Date = Date()
    @State var showChart: Bool = false
    let id: String

    // Initializer used in AddSaved view
    init(id: String, curr: CurrencyInfo, vm: MainViewModel, isSaved: Bool, isFavorite: Bool) {
        _viewModel = StateObject(wrappedValue: CryptoDetailViewModel(id: id, currency: curr, vm: vm, isFavorite: isFavorite))
        self.id = id
        self.isSaved = isSaved
    }
    
    // Initializer used in PersonalList view
    init(info: CryptoInfo, vm: MainViewModel) {
        self.id = info.api_id
        self.isSaved = true
        _viewModel = StateObject(wrappedValue: CryptoDetailViewModel(info: info, vm: vm))
    }

    init(info: CryptoInfo) { // For preview
        let preloadedViewModel = CryptoDetailViewModel(id: "", currency: CurrencyInfo(), vm: MainViewModel(), isFavorite: true)
        preloadedViewModel.cryptoInfo = info
        preloadedViewModel.isLoaded = true
        _viewModel = StateObject(wrappedValue: preloadedViewModel)
        self.id = ""
        self.isSaved = true
    }

    var body: some View {
        NavigationView {
            if viewModel.isLoaded {
                if let cryptoInfo = viewModel.cryptoInfo {
                    // Info available -> no error
                    ZStack {
                        Form {
                            Section("Crypto") {
                                HStack(alignment: .center) {
                                    AsyncImage(url: cryptoInfo.imageUrl, scale:3)
                                        .frame(width: 100.0, height: 100.0)
                                    Text(cryptoInfo.name)
                                        .fontWeight(.bold)
                                        .font(.title)
                                }
                                .frame(maxWidth: .infinity)
                                
                                Row(fieldName: "Symbol", value: cryptoInfo.symbol)
                                Row(fieldName: "Price", value: cryptoInfo.price)
                                Row(fieldName: "% change 24h", value: cryptoInfo.priceChange)
                                Row(fieldName: "Volume", value: cryptoInfo.volume)
                                Row(fieldName: "Market Cap", value: cryptoInfo.marketCap)
                                
                            }
                            if !isSaved {
                                Button("Add to saved crypto") {
                                    viewModel.addSaved(id: self.id)
                                    isSaved = true
                                }
                            }
                            Section("Chart") {
                                HStack{ // Select day from when data for chart is requested
                                    Text("Show data from").opacity(0.4)
                                    Spacer()
                                    DatePicker("", selection: $dateFrom, displayedComponents: .date)
                                }
                                let dayCount = Calendar.current.dateComponents([.day], from: dateFrom, to: Date()).day ?? 0
                                if dayCount > 0 {
                                    HStack {
                                        Spacer()
                                        
                                        Text("Graph for \(dayCount) days")
                                            .opacity(0.4)
                                        
                                        Button {
                                            withAnimation(.spring()) {
                                                showChart = true // Hides this view by overlapping chart
                                            }
                                        } label: {
                                            Image(systemName: "chart.line.uptrend.xyaxis")
                                        }
                                        Spacer()
                                        
                                    }
                                }
                            }
                        }
                        if showChart {
                            let dayCount = Calendar.current.dateComponents([.day], from: dateFrom, to: Date()).day ?? 0
                            ChartWrapperView(vm: viewModel, id: self.id, days: dayCount) // Chart view
                                .transition(.move(edge: .bottom))
                            VStack {
                                Spacer()
                                HStack {
                                    Button { // Button to close chart
                                        withAnimation(.bouncy) {
                                            showChart = false
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundStyle(.red)
                                            .rotationEffect(.degrees(45.0))
                                            .font(.system(size: 50))
                                            .padding(.leading, 20.0)
                                            .padding(.bottom, 60.0)
                                    }
                                    Spacer()
                                }
                            }.transition(.move(edge: .bottom))
                        }
                    }
                } else if viewModel.isError {
                    Text("Failed to load crypto information.")
                        .foregroundColor(.red)
                }
            } else { // VM didn't load yet
                Text("Loading...")
            }
        }
        .navigationTitle("Crypto Detail")
    }
}
#Preview {
    CryptoDetailView(info: CryptoInfo(name: "testCrypto", symbol: "TEST", price: "123243.23 $", marketCap: "2.3B$", volume: "3",
        imageUrl: URL(filePath:
                        "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400")!, priceChange: "-10%", isSaved: false, api_id: "t8ab", isFavorite: true))
}
