//
//  NameAndDate.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 3/1/25.
//

import SwiftUI

struct NameAndDate: View {
    
    var id: String
    var expirationDate: Date
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d 'of' MMMM"  // "d" for day, "MMMM" for full month name
        formatter.locale = Locale(identifier: "en_US")  // Ensure "of" is in English
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"  // 24-hour format: Hours:Minutes:Seconds
        formatter.locale = Locale.current   // Use the current locale
        return formatter
    }()
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(id.uppercased())")
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            Text("\(expirationDate, formatter: Self.dateFormatter)")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(expirationDate, formatter: Self.timeFormatter)")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

#Preview {
    NameAndDate(id: "Bitcoin", expirationDate: Date())
}
