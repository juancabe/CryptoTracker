//
//  CryptoListItemView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 24/12/24.
//

import SwiftUI

struct CryptoListItemView: View {
    
    private var crypto: CryptoInfo
    
    var body: some View {
        HStack {
            AsyncImage(url: crypto.imageUrl, scale: 6.0)
                .frame(width: 60.0, height: 60.0)
                .cornerRadius(12.0)
            
            VStack {
                Text(crypto.name)
                    .font(.title)
                Text(crypto.symbol)
                    .font(.subheadline)
            }
            
            Spacer()
            
            VStack {
                Text(crypto.price)
                    .font(.headline)
                Text(crypto.marketCap)
            }
            
        }
    }
    
    init(crypto: CryptoInfo) {
        self.crypto = crypto
    }
    
}

#Preview {
    CryptoListItemView(
        crypto: CryptoInfo(name: "Bitcoin",
                          symbol: "BTC",
                          price: "110230.54 $",
                          marketCap: "2B$",
                          imageUrl: URL( filePath: "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400")!,
                           priceChange: "10%", isFavorite: true))
}
