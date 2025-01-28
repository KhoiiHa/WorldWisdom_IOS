//
//  ExplorerView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 28.01.25.
//

import SwiftUI

struct ExplorerView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel
    @State private var selectedCategory: String? = nil
    @State private var searchQuery: String = "" // Suchbegriff speichern
    @State private var isLoading: Bool = false // Ladeindikator
    @State private var errorMessage: String? = nil // Fehlernachricht speichern
    
    var body: some View {
        VStack {
            Text("Explorer View")
                .font(.largeTitle)
                .padding()

            // Suchleiste
            TextField("Suche nach Zitaten...", text: $searchQuery, onCommit: {
                // Wenn die Eingabetaste gedrückt wird, suche nach Zitaten
                searchQuotes()
            })
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()

            // Fehlernachricht anzeigen
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            // Kategorien anzeigen
            List(quoteViewModel.categories, id: \.self) { category in
                Button(action: {
                    // Wenn eine Kategorie ausgewählt wird, lade Zitate dieser Kategorie
                    loadQuotesByCategory(category)
                }) {
                    Text(category)
                        .font(.headline)
                        .padding()
                }
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }

            // Anzeige der Zitate
            if isLoading {
                ProgressView("Lade Zitate...") // Ladeindikator
                    .padding()
            } else {
                List(quoteViewModel.quotes, id: \.id) { quote in
                    VStack(alignment: .leading) {
                        Text(quote.quote)
                            .font(.body)
                        Text("- \(quote.author)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }

            Spacer()
        }
        .onAppear {

            Task {
                await quoteViewModel.loadCategories() // Lädt die Kategorien asynchron
            }
        }
        .padding()
    }
    
    private func searchQuotes() {
        guard !searchQuery.isEmpty else {
            // Wenn der Suchbegriff leer ist, tue nichts
            return
        }
        
        isLoading = true
        errorMessage = nil
        // Aufruf der bereits vorhandenen `searchQuotes` Funktion im ViewModel
        Task {
            do {
                // Suche nach Zitaten mit dem eingegebenen Suchbegriff
                try await quoteViewModel.searchQuotes(query: searchQuery)
            } catch {
                // Fehlerbehandlung (z.B. keine Ergebnisse)
                errorMessage = "Fehler beim Suchen: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func loadQuotesByCategory(_ category: String) {
        selectedCategory = category
        isLoading = true
        errorMessage = nil
        
        // Aufruf der `loadQuotesByCategory` Funktion im ViewModel
        Task {
            await quoteViewModel.loadQuotesByCategory(category: category)
            isLoading = false
        }
    }
}

#Preview {
    ExplorerView(quoteViewModel: QuoteViewModel())
}
