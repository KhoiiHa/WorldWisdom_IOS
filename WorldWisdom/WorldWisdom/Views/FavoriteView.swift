//
//  FavoriteView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct FavoriteView: View {
    @StateObject private var viewModel = QuoteViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    // Fehleranzeige, wenn etwas schiefgeht
                    Text(errorMessage)
                        .font(.title3)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.quotes.isEmpty {
                    // Anzeige, wenn keine Favoriten vorhanden sind
                    Text("Keine Favoriten vorhanden.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    // Liste der Favoriten mit Swipe-to-Delete
                    List {
                        ForEach(viewModel.quotes) { quote in
                            NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: viewModel)) {
                                VStack(alignment: .leading) {
                                    Text(quote.quote)
                                        .font(.headline)
                                        .lineLimit(2)
                                        .padding(.bottom, 2)
                                    
                                    Text("- \(quote.author)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteFavorite)
                    }
                    .listStyle(InsetGroupedListStyle()) // Verbesserte Darstellung der Liste
                }
            }
            .onAppear {
                loadFavoriteQuotes()
            }
            .navigationTitle("Favoriten")
        }
    }
    
    // Lädt die Favoriten aus Firestore
    private func loadFavoriteQuotes() {
        Task {
            do {
                // Hole die Favoriten-Zitate aus Firestore (von der Firebase-Datenbank)
                try await viewModel.loadFavoriteQuotes()
            } catch {
                // Fehlerbehandlung
                viewModel.errorMessage = "Fehler beim Laden der Favoriten: \(error.localizedDescription)"
            }
        }
    }
    
    // Löscht ein Zitat aus den Favoriten
    private func deleteFavorite(at offsets: IndexSet) {
        for index in offsets {
            let quote = viewModel.quotes[index]
            Task {
                do {
                    // Lösche das Zitat aus Firestore
                    try await viewModel.removeFavoriteQuote(quote)
                    // Entferne das Zitat lokal aus der Liste
                    viewModel.quotes.remove(at: index)
                } catch {
                    // Fehlerbehandlung
                    viewModel.errorMessage = "Fehler beim Löschen des Zitats: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    FavoriteView()
}
