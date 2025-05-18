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
    @State private var selectedAuthor: String? = nil
    @EnvironmentObject var networkMonitor: NetworkMonitor

    // MARK: - Favoritenlogik
    /// Prüft, ob ein Autor mindestens 3 Favoriten-Zitate hat
    func isFavoriteAuthor(_ author: String) -> Bool {
        let count = quotes.filter { $0.author == author && $0.isFavorite }.count
        return count >= 3
    }

    // MARK: - Autorenfilter & -Liste
    /// Einzigartige Autoren mit optionalem Bild-URL, gefiltert nach Suchtext
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
                if !networkMonitor.isConnected {
                    Text("⚠️ Offline-Modus – Lokale Autoren-Daten werden angezeigt")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                // Suchfeld für Autoren
                TextField("Autor suchen", text: $searchText)
                    .padding(10)
                    .background(
                        LinearGradient(
                            colors: [Color("mainBlue").opacity(0.10), Color("cardBackground")],
                            startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("mainBlue").opacity(0.15), lineWidth: 1)
                    )
                    .padding(.horizontal)
                ScrollView {
                    if uniqueAuthors.isEmpty {
                        // Anzeige, wenn keine Autoren gefunden wurden
                        VStack {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.largeTitle)
                                .foregroundColor(Color("secondaryText"))
                            Text("Keine Autoren verfügbar.")
                                .foregroundColor(Color("secondaryText"))
                                .font(.body)
                        }
                        .padding()
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(Array(uniqueAuthors.enumerated()), id: \.element.author) { index, item in
                            VStack(spacing: 6) {
                                Button(action: {
                                    selectedAuthor = item.author
                                }) {
                                    VStack(spacing: 6) {
                                        WebImage(url: URL(string: item.imageUrl ?? "https://via.placeholder.com/100"))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 68, height: 68)
                                            .clipShape(Circle())
                                            .shadow(color: isFavoriteAuthor(item.author) ? Color("mainBlue").opacity(0.25) : Color("buttonColor").opacity(0.06), radius: isFavoriteAuthor(item.author) ? 8 : 4)

                                        Text(item.author)
                                            .font(.footnote)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color("primaryText"))
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .frame(width: 78)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 8)
                                    .background(
                                        LinearGradient(
                                            colors: index % 2 == 0 ?
                                                [Color("mainBlue").opacity(0.11), Color("cardBackground")] :
                                                [Color("buttonColor").opacity(0.08), Color("cardBackground")],
                                            startPoint: .top, endPoint: .bottom)
                                    )
                                    .overlay(
                                        Circle()
                                            .strokeBorder(isFavoriteAuthor(item.author) ? Color("mainBlue") : Color.clear, lineWidth: 2)
                                            .frame(width: 74, height: 74)
                                            .offset(y: -38)
                                    )
                                    .cornerRadius(14)
                                    .shadow(color: Color("buttonColor").opacity(0.03), radius: 2, x: 0, y: 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            // Navigation zur Detailansicht des ausgewählten Autors
            .navigationDestination(item: $selectedAuthor) { author in
                AutorDetailView(authorName: author)
                    .environmentObject(networkMonitor)
            }
        }
        .background(Color("background").ignoresSafeArea())
    }
}
