//
//  AutorDetailView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct AutorDetailView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel // ViewModel für das Zitat
    @State private var searchQuery: String = "" // Suchbegriff speichern
    @State private var searchResults: [Quote] = [] // Ergebnisse der Suche
    let quote: Quote // Nutzt die Quote-Struktur
    
    @State private var isFavorite: Bool // Favoritenstatus innerhalb der View

    init(quote: Quote, quoteViewModel: QuoteViewModel) {
        self.quote = quote
        self._isFavorite = State(initialValue: quote.isFavorite) // Initialisieren mit dem Wert aus der Quote-Struktur
        self.quoteViewModel = quoteViewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Suchleiste
                TextField("Nach Autor suchen...", text: $searchQuery, onCommit: {
                    searchAuthors() // Bei Enter drücken nach Autor suchen
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()

                // Zitat Details
                Text(quote.author)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("Kategorie: \(quote.category)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Text("\"\(quote.quote)\"")
                    .font(.title2)
                    .italic()
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                // Tags anzeigen
                if !quote.tags.isEmpty {
                    Text("Tags: \(quote.tags.joined(separator: ", "))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        await toggleFavoriteStatus() // asynchrone Funktion wird hier aufgerufen
                    }
                }) {
                    HStack {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .gray)
                        Text(isFavorite ? "Favorit" : "Zu Favoriten hinzufügen")
                            .font(.headline)
                            .foregroundColor(isFavorite ? .red : .blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.top)

                // Quellen-Link
                if let url = URL(string: quote.source), UIApplication.shared.canOpenURL(url) {
                    Link("Mehr über \(quote.author)", destination: url)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("Ungültiger Link zur Quelle.")
                        .foregroundColor(.red)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                // Suchergebnisse (falls vorhanden)
                if !searchResults.isEmpty {
                    Text("Ergebnisse für \(searchQuery):")
                        .font(.headline)
                        .padding(.top)

                    ForEach(searchResults, id: \.id) { result in
                        Text(result.quote)
                            .font(.body)
                            .padding(.top, 5)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Autor Details")
        .onAppear {
            // Optional: Funktionen bei Anzeige der View aufrufen, z.B. Favoritenstatus überprüfen
        }
    }

    // Funktion zum Suchen nach Autoren
    private func searchAuthors() {
        guard !searchQuery.isEmpty else { return }
        
        // Simuliere eine Autoren-Suche
        let results = quoteViewModel.quotes.filter { $0.author.lowercased().contains(searchQuery.lowercased()) }
        searchResults = results
    }
    
    private func toggleFavoriteStatus() async {
        isFavorite.toggle() // Favoritenstatus toggeln
        await quoteViewModel.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
    }
}

#Preview {
    AutorDetailView(
        quote: Quote(
            id: "1",
            author: "Albert Einstein",
            quote: "Imagination is more important than knowledge.",
            category: "Inspiration",
            tags: ["Knowledge", "Imagination"],
            isFavorite: false,
            description: "Albert Einstein was a theoretical physicist known for developing the theory of relativity.",
            source: "https://en.wikipedia.org/wiki/Albert_Einstein"
        ),
        quoteViewModel: QuoteViewModel() // ViewModel hier einfügen
    )
}
