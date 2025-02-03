//
//  AutorDetailView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct AutorDetailView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel
    @State private var searchQuery: String = ""
    @State private var searchResults: [Quote] = []
    let quote: Quote
    @State private var isFavorite: Bool
    
    init(quote: Quote, quoteViewModel: QuoteViewModel) {
        self.quote = quote
        self._isFavorite = State(initialValue: quote.isFavorite ?? false)
        self.quoteViewModel = quoteViewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Suchleiste für Autoren
                TextField("Nach Autor suchen...", text: $searchQuery)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    .onChange(of: searchQuery) { newValue, _ in
                        // Hier wird die Suchanfrage direkt an das ViewModel weitergegeben
                        searchResults = quoteViewModel.searchAuthors(query: newValue)
                    }
                
                // Zitat-Details
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
                
                // Favoriten-Button
                Button(action: {
                    Task {
                        await quoteViewModel.updateFavoriteStatus(for: quote, isFavorite: !isFavorite)
                        isFavorite.toggle()
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
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    .shadow(radius: 5)
                }
                .padding(.top)
                
                // Quellen-Link
                if let url = URL(string: quote.source) {
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
                
                // Suchergebnisse
                if !searchResults.isEmpty {
                    Text("Ergebnisse für \(searchQuery):")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(searchResults, id: \.id) { result in
                        Text(result.quote)
                            .font(.body)
                            .padding(.top, 5)
                    }
                } else if !searchQuery.isEmpty {
                    Text("Keine Ergebnisse für \(searchQuery) gefunden.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Autor Details")
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
        quoteViewModel: QuoteViewModel()
    )
}
