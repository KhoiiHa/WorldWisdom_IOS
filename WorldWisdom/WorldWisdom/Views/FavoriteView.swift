//
//  FavoriteView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct FavoriteView: View {
    @StateObject private var viewModel = QuoteViewModel() // Verwende den ViewModel für das Abrufen von Zitat-Daten

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.quotes.isEmpty {
                    // Anzeige, wenn keine Favoriten vorhanden sind
                    Text("Keine Favoriten vorhanden.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    // Liste der Favoriten
                    List(viewModel.quotes) { quote in
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
                    .listStyle(InsetGroupedListStyle()) // Verbesserte Darstellung der Liste
                }
            }
            .onAppear {
                loadFavoriteQuotes() // Zitate laden, wenn die View erscheint
            }
            .navigationTitle("Favoriten")
        }
    }
    
    // Lädt die Favoriten aus Firestore
    private func loadFavoriteQuotes() {
        Task {
            do {
                // Hole die Favoriten-Zitate aus Firestore (von der Firebase-Datenbank)
                try await viewModel.loadFavoriteQuotes() // Dies muss im ViewModel implementiert werden
            } catch {
                // Fehlerbehandlung
                viewModel.errorMessage = "Fehler beim Laden der Favoriten: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    FavoriteView()
}
