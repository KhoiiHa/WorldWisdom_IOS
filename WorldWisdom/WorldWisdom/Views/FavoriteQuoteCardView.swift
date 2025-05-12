//
//  FavoriteQuoteCardView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//

/// Zeigt eine einzelne Zitatkarte im Favoritenbereich an.
/// Beinhaltet Zitattext, Autor, Bild, Favoritenstatus und Autor-Dropdown.
import SwiftUI
import SDWebImageSwiftUI

struct FavoriteQuoteCardView: View {
    @EnvironmentObject var favoriteManager: FavoriteManager
    let quote: Quote
    @State private var showAuthorDetails = false
    @State private var navigateToDetail = false

    // MARK: - View Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Button(action: {
                    Task {
                        let convertedQuote = Quote(
                            id: quote.id,
                            author: quote.author,
                            quote: quote.quote,
                            category: quote.category,
                            tags: quote.tags,
                            isFavorite: true,
                            description: quote.description,
                            source: quote.source,
                            authorImageURLs: quote.authorImageURLs,
                            authorImageData: nil
                        )
                        await favoriteManager.updateFavoriteStatus(for: convertedQuote, isFavorite: true)
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .padding(6)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            HStack {
                WebImage(url: URL(string: quote.authorImageURLs?.first ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .shadow(radius: 3)

                Text("- \(quote.author)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()
            }
            
            // Zitat Text
            Button(action: {
                navigateToDetail = true
            }) {
                Text("„\(quote.quote)“")
                    .font(.system(.body, design: .serif))
                    .italic()
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Button für Dropdown
            Button(action: {
                withAnimation {
                    showAuthorDetails.toggle()
                }
            }) {
                HStack {
                    Text(showAuthorDetails ? "Details ausblenden" : "Mehr über den Autor")
                        .font(.caption)
                        .foregroundColor(.blue) // Kräftigeres Blau für Interaktivität
                    Image(systemName: showAuthorDetails ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
                .padding(.top, 5)
            }

            // Autor-Infos (Dropdown)
            if showAuthorDetails {
                authorInfoCard
                    .transition(.slide)  // Sanfte Animation beim Einblenden
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.gray.opacity(0.2)]), // Sanfter blauer Verlauf
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )  // Die Hintergrundfarbe bleibt hier
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
        .navigationDestination(isPresented: $navigateToDetail) {
            AutorDetailView(authorName: quote.author, selectedQuoteText: quote.quote)
        }
    }

    // MARK: - Autor Info Card (Dropdown)
    private var authorInfoCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Über \(quote.author):")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(quote.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8)) // Weiß mit leichtem Durchschein-Effekt
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true) // Verhindert Textabschneiden
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.gray.opacity(0.7)]), // Blau-Grau Verlauf
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.vertical, 5)
    }
}
