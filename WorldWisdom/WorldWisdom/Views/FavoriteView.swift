//
//  FavoriteView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct FavoriteView: View {
    @EnvironmentObject private var quoteViewModel: QuoteViewModel
    @State private var showCategoryFilter = false
    @State private var selectedCategory: String? = nil
    @State private var showErrorMessage = false  // Zustand für Fehleranzeige im UI
    
    var body: some View {
        NavigationStack {
            VStack {
                if quoteViewModel.favoriteQuotes.isEmpty {
                    emptyStateView
                } else {
                    quoteListView
                }
                
                // Fehleranzeige im UI (optional)
                if showErrorMessage {
                    Text("Fehler beim Laden oder Speichern eines Favoriten!")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Favoriten")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    addQuoteButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    categoryFilterButton
                }
            }
            .sheet(isPresented: $showCategoryFilter) {
                CategoryFilterView(
                    categories: Set(quoteViewModel.favoriteQuotes.map { $0.category }),
                    selectedCategory: $selectedCategory
                )
            }
            .onAppear {
                loadFavoriteQuotes()
            }
            .onChange(of: quoteViewModel.favoriteQuotes) {
                loadFavoriteQuotes()
            }
        }
    }
    
    // Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Du hast noch keine Favoriten gespeichert.")
                .foregroundColor(.secondary)
                .font(.system(size: 18, weight: .semibold))
        }
        .padding()
    }
    
    // List of Quotes
    private var quoteListView: some View {
        List {
            ForEach(filteredFavoriteQuotes()) { quote in
                NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: quoteViewModel)) {
                    FavoriteQuoteCardView(quote: quote, unfavoriteAction: {
                        unfavoriteQuote(quote)
                    })
                }
            }
        }
    }
    
    // Buttons
    private var categoryFilterButton: some View {
        Button(action: { showCategoryFilter = true }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundColor(.blue)
        }
    }

    private var addQuoteButton: some View {
        NavigationLink(destination: AddQuoteView()) {
            Text("Neues Zitat erstellen")
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .padding(8)
                .background(Capsule().stroke(Color.blue, lineWidth: 1))
        }
    }

    // Hinzufügen eines Favoriten
    // Hinzufügen eines Favoriten
    private func addFavoriteQuote(_ quote: Quote) {
        Task {
            await quoteViewModel.addFavoriteQuote(quote)
            showErrorMessage = false  // Fehleranzeige zurücksetzen, falls erfolgreich
        }
    }

    // Entfernen eines Favoriten
    private func unfavoriteQuote(_ quote: Quote) {
        Task {
            do {
                try await quoteViewModel.removeFavoriteQuote(quote)
                showErrorMessage = false
            } catch {
                print("Fehler beim Entfernen des Favoriten: \(error.localizedDescription)")
                showErrorMessage = true
            }
        }
    }

    // Laden der Favoriten
    private func loadFavoriteQuotes() {
        Task {
            do {
                try await quoteViewModel.loadFavoriteQuotes()
                showErrorMessage = false
            } catch {
                print("Fehler beim Laden der Favoriten: \(error.localizedDescription)")
                showErrorMessage = true
            }
        }
    }
    
    // Filtered Quotes
    private func filteredFavoriteQuotes() -> [Quote] {
        if let selectedCategory = selectedCategory {
            return quoteViewModel.favoriteQuotes.filter { $0.category == selectedCategory }
        }
        return quoteViewModel.favoriteQuotes
    }
}

#Preview {
    FavoriteView()
}
