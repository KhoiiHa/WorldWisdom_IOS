//
//  FavoriteQuoteCardView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//

/// Zeigt eine einzelne Zitatkarte im Favoritenbereich an.
/// Beinhaltet Zitattext, Autor, Bild, Favoritenstatus
import SwiftUI
import SDWebImageSwiftUI

struct FavoriteQuoteCardView: View {
    @EnvironmentObject var favoriteManager: FavoriteManager
    let quote: Quote

    // MARK: - View Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Autor Bild und Name
            HStack {
                WebImage(url: URL(string: quote.authorImageURLs?.first ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .shadow(radius: 3)

                Text("- \(quote.author)")
                    .font(.caption)
                    .foregroundColor(Color("secondaryText"))

                Spacer()
            }
            
            // MARK: - Zitat Text (nur Anzeige, keine Navigation/Interaktion)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "quote.opening")
                        .font(.subheadline)
                        .foregroundColor(Color("mainBlue"))
                        .padding(.bottom, 0)
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("„\(quote.quote)“")
                        .font(.system(.body, design: .serif))
                        .italic()
                        .foregroundColor(Color("primaryText"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color("cardBackground"))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("cardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("secondaryText").opacity(0.10), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("buttonColor").opacity(0.07), radius: 6, x: 0, y: 3)
    }
}
