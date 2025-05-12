//
//  GalerieView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 14.02.25.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

/// Galerie-Ansicht zur Anzeige aller Autoren, deren Zitate lokal gespeichert sind.
/// Unterstützt Suche, Favoriten-Erkennung (basierend auf gespeicherten Zitaten) und Navigation zur Detailansicht.

// MARK: - GalerieScreen
struct GalerieScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query var quotes: [QuoteEntity]
    @State private var searchText: String = ""

    // MARK: - Favoritenlogik
    func isFavoriteAuthor(_ author: String) -> Bool {
        let count = quotes.filter { $0.author == author && $0.isFavorite }.count
        return count >= 3
    }

    // MARK: - Autorenfilter & -Liste
    var uniqueAuthors: [(author: String, imageUrl: String?)] {
        var seen = Set<String>()
        let result: [(author: String, imageUrl: String?)] = quotes
            .filter { quote in
                let trimmed = quote.author.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.lowercased().contains(searchText.lowercased()) || searchText.isEmpty
            }
            .compactMap { quote in
                let trimmedAuthor = quote.author.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedAuthor.isEmpty, !seen.contains(trimmedAuthor) else { return nil }
                seen.insert(trimmedAuthor)
                return (trimmedAuthor, quote.authorImageURLs.first ?? "https://via.placeholder.com/100")
            }

        return result.sorted { $0.author < $1.author }
    }


    // MARK: - View Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                TextField("Autor suchen", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                ScrollView {
                    if uniqueAuthors.isEmpty {
                        Text("Keine Autoren verfügbar.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(uniqueAuthors, id: \.author) { item in
                            NavigationLink(destination: AutorDetailView(authorName: item.author)) {
                                VStack(spacing: 8) {
                                    WebImage(url: URL(string: item.imageUrl ?? "https://via.placeholder.com/100"))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)

                                    Text(item.author)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .frame(width: 90)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isFavoriteAuthor(item.author) ? Color.red : Color.clear, lineWidth: 2)
                                )
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
