//
//  FavoriteView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct FavoriteView: View {
    @StateObject private var favoriteManager = FavoriteManager()

    var body: some View {
        NavigationView {
            List {
                // Anzeige der Favoriten oder leere Ansicht
                if favoriteManager.favoriteQuotes.isEmpty {
                    emptyStateView
                } else {
                    ForEach(favoriteManager.favoriteQuotes) { quote in
                        FavoriteQuoteCardView(quote: quote, unfavoriteAction: {
                            await removeFavorite(quote)
                        })
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
                await favoriteManager.loadFavoriteQuotes()
            }
        }
    }
    
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

    private func removeFavorite(_ quote: Quote) async {
        await favoriteManager.removeFavoriteQuote(quote)
    }
}
