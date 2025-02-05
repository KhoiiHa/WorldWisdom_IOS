//
//  FavoriteQuoteCardView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//
import SwiftUI

struct FavoriteQuoteCardView: View {
    let quote: Quote
    let unfavoriteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.quote)
                .font(.body)
                .foregroundColor(.primary)

            Text("- \(quote.author)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
        .overlay(alignment: .topTrailing) {
            Button(action: unfavoriteAction) {
                Image(systemName: "heart.slash")
                    .foregroundColor(.red)
                    .padding(8)
            }
        }
    }
}


