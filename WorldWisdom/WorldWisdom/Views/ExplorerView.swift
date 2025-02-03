//
//  ExplorerView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 28.01.25.
//

import SwiftUI

struct ExplorerView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel
    @State private var searchQuery: String = "" // Suchbegriff speichern
    @State private var errorMessage: String? = nil // Fehlernachricht speichern
    
    // Gefilterte Zitate basierend auf der Suche
    private var filteredQuotes: [Quote] {
        if searchQuery.isEmpty {
            return quoteViewModel.quotes // Alle Zitate anzeigen, wenn kein Filter aktiv ist
        } else {
            return quoteViewModel.quotes.filter { $0.author.localizedCaseInsensitiveContains(searchQuery) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Explorer View")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Suchleiste für Autoren
                HStack {
                    TextField("Suche nach Autoren...", text: $searchQuery)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .onChange(of: searchQuery) { newValue, _ in
                            // Automatische Filterung beim Tippen
                            searchQuotes(newValue)
                        }
                    Button(action: {
                        searchQuotes(searchQuery) // Manuelle Suche auslösen
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .padding([.leading, .trailing])

                // Fehlernachricht anzeigen
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }

                // Anzeige der Zitate
                if filteredQuotes.isEmpty {
                    Text("Keine Zitate gefunden.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredQuotes, id: \.id) { quote in
                        VStack(alignment: .leading) {
                            Text(quote.quote)
                                .font(.body)
                                .padding(.bottom, 2)
                            
                            Text("- \(quote.author)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            // NavigationLink zu AutorDetailView
                            NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: quoteViewModel)) {
                                Text("Mehr über \(quote.author)")
                                    .font(.body)
                                    .foregroundColor(.blue)
                                    .padding(.top, 5)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }

    private func searchQuotes(_ query: String) {
        // Verhindere unnötige Filterung, wenn die Eingabe leer ist
        if query.isEmpty {
            return
        }
        
        errorMessage = nil

        // Filtere die Zitate basierend auf dem Suchbegriff
        let filtered = quoteViewModel.quotes.filter { $0.author.localizedCaseInsensitiveContains(query) }
        
        // Aktualisiere den ViewModel mit den gefilterten Zitaten
        Task {
            await MainActor.run {
                quoteViewModel.quotes = filtered
            }
        }
    }
}

#Preview {
    ExplorerView(quoteViewModel: QuoteViewModel())
}
