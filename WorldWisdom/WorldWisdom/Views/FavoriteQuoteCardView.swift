//
//  FavoriteQuoteCardView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//
import SwiftUI

struct FavoriteQuoteCardView: View {
    @ObservedObject var favoriteManager: FavoriteManager
    let quote: Quote
    @State private var showErrorMessage: Bool = false
    @State private var isRemoving: Bool = false
    @State private var showAuthorDetails: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Autorenbild anzeigen, falls vorhanden (das erste Bild aus authorImageURLs)
            if let imageUrlString = quote.authorImageURLs?.first, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 40, height: 40)
                }
            }

            // Zitat anzeigen
            Text("„\(quote.quote)“")
                .font(.body)
                .italic()
                .foregroundColor(.primary)
                .lineLimit(3)  // Maximale Zeilenanzahl für das Zitat
                .padding(.bottom, 5)

            // Autor des Zitats
            Text("- \(quote.author)")
                .font(.caption)
                .foregroundColor(.secondary)

            // Button zum Anzeigen von weiteren Autoreninfos
            Button(action: {
                showAuthorDetails.toggle()
            }) {
                Text(showAuthorDetails ? "Weniger erfahren" : "Mehr erfahren")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }

            // Detaillierte Informationen über den Autor
            if showAuthorDetails {
                VStack(alignment: .leading, spacing: 8) {
                    // Hier könnten mehr Details zu diesem Autor angezeigt werden
                    Text("Biografie:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Dies ist eine kurze Biografie des Autors. Hier könnte ein Abschnitt aus Wikipedia oder ein inspirierendes Zitat des Autors stehen.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(5)
                        .truncationMode(.tail)
                }
                .padding(.top, 8)
                .transition(.move(edge: .bottom))
            }

            // Fehleranzeige (falls nötig)
            if showErrorMessage {
                Text("Fehler beim Entfernen des Favoriten. Bitte versuchen Sie es später erneut.")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))  // Abrundung des Cards
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)  
    }
}
