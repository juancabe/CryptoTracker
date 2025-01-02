//
//  CryptoListItemView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 24/12/24.
//

import SwiftUI

// View CryptoInfo within a list item
struct CryptoListItemView: View {
    
    @ObservedObject var crypto: CryptoInfo
    
    var body: some View {
        
        HStack {
            // Dynamic load of image
            AsyncImage(url: crypto.imageUrl, scale: 6.0)
                .frame(width: 60.0, height: 60.0)
                .cornerRadius(12.0)
            
            // Crypto's name and symbol
            VStack (alignment: .leading) {
                Text(crypto.name)
                    .font(.title)
                Text(crypto.symbol)
                    .font(.subheadline)
            }
            
            Spacer()
            // Crypto's price and price change
            VStack (alignment: .trailing) {
                Text(crypto.price)
                    .font(.headline)
                Text(crypto.priceChange)
                    .foregroundStyle(
                        crypto.priceChange.hasPrefix("-") ?
                            .red : // Red if price went down
                            .green // Green if price went up
                    )
            }
        }
    }
}

#Preview {
    CryptoListItemView(
        crypto: CryptoInfo(name: "Bitcoin",
                          symbol: "BTC",
                          price: "110230.54 $",
                        marketCap: "2B$",
                           volume: "vol",
                           
                          imageUrl: URL( filePath: "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400")!,
                           priceChange: "10%", isSaved: true,api_id: "t78dwag", isFavorite: true
                           ))
}
