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
    @State var isFavorite: Bool
    let id: String

    init(id: String, curr: CurrencyInfo, vm: CryptoList, isFav: Bool) {
        _viewModel = StateObject(wrappedValue: CryptoDetailViewModel(id: id, currency: curr, vm: vm))
        self.id = id
        self.isFavorite = isFav
    }

    init(info: CryptoInfo) { // For preview
        let preloadedViewModel = CryptoDetailViewModel(id: "", currency: CurrencyInfo(), vm: CryptoList())
        preloadedViewModel.cryptoInfo = info
        preloadedViewModel.isLoaded = true
        _viewModel = StateObject(wrappedValue: preloadedViewModel)
        self.id = ""
        self.isFavorite = true
    }

    var body: some View {
        if viewModel.isLoaded {
            if let cryptoInfo = viewModel.cryptoInfo {
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
                    }
                    Section("Crypto Details") {
                        Row(fieldName: "Symbol", value: cryptoInfo.symbol)
                        Row(fieldName: "Price", value: cryptoInfo.price)
                        Row(fieldName: "Market Cap", value: cryptoInfo.marketCap)
                    }
                    if !isFavorite {
                        Button("Add to favorites") {
                            viewModel.addFavorite(id: self.id)
                            isFavorite = true
                        }
                    }
                   
                    
                }
            } else if viewModel.isError {
                Text("Failed to load crypto information.")
                    .foregroundColor(.red)
            }
        } else {
            Text("Loading...")
        }
    }
}

#Preview {
    CryptoDetailView(info: CryptoInfo(name: "testCrypto", symbol: "TEST", price: "123243.23 $", marketCap: "2.3B$",
        imageUrl: URL(filePath:
        "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400")!,
        priceChange: "-10%", isFavorite: false))
}
