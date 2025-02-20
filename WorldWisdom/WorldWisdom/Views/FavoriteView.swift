//
//  FavoriteView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct FavoriteView: View {
    @StateObject private var favoriteManager = FavoriteManager()
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String?
    @StateObject private var quoteViewModel = QuoteViewModel()

    var body: some View {
        List {
            // Anzeige der Favoriten oder leere Ansicht
            if favoriteManager.favoriteQuotes.isEmpty {
                emptyStateView
            } else {
                ForEach(favoriteManager.favoriteQuotes) { quote in
                    FavoriteQuoteCardView(favoriteManager: favoriteManager, quote: quote)
                        .swipeActions {
                            Button(role: .destructive) {
                                Task {
                                    await removeFavorite(quote)
                                }
                            } label: {
                                Label("Entfernen", systemImage: "trash.fill")
                            }
                        }
                }
            }
        }
        
        .navigationTitle("Favoriten")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { Task { await favoriteManager.loadFavoriteQuotes() } }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: AddQuoteView(quoteToEdit: nil)) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
        .task {
            await favoriteManager.loadFavoriteQuotes() // Lade die Favoriten bei Initialisierung
        }
        .alert(isPresented: $showErrorMessage) {
            Alert(title: Text("Fehler"), message: Text(errorMessage ?? "Unbekannter Fehler"), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "star.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("Noch keine Favoriten gespeichert.")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }

    // MARK: - Remove Favorite
    private func removeFavorite(_ quote: Quote) async {
        do {
            // Fehlerbehandlung und Favoriten entfernen
            try await favoriteManager.removeFavoriteQuote(quote)
            showErrorMessage = false  // Fehleranzeige zurücksetzen
        } catch let error as FirebaseError {
            // Fehlerbehandlung je nach Fehlerart
            showErrorMessage = true
            errorMessage = error.localizedDescription
            print("Fehler beim Entfernen des Favoriten: \(error.localizedDescription)")
        } catch {
            // Allgemeine Fehlerbehandlung
            showErrorMessage = true
            errorMessage = "Ein unerwarteter Fehler ist aufgetreten."
            print("Unbekannter Fehler: \(error.localizedDescription)")
        }
    }
}
