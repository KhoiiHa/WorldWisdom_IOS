//
//  FavoriteView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct FavoriteView: View {
    @EnvironmentObject private var viewModel: QuoteViewModel
    @State private var selectedCategory: String? = nil
    @State private var showCategoryFilter = false

    var body: some View {
        NavigationStack {
            VStack {
                // Filter-Bereich
                if !viewModel.quotes.isEmpty {
                    filterBar
                }

                // Inhalt
                if filteredQuotes.isEmpty {
                    emptyStateView
                } else {
                    quoteListView
                }
            }
            .navigationTitle("Favoriten")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    addQuoteButton // Button zum Hinzufügen eines neuen Zitats
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    categoryFilterButton
                }
            }
            .sheet(isPresented: $showCategoryFilter) {
                CategoryFilterView(
                    categories: Set(viewModel.quotes.map { $0.category }),
                    selectedCategory: $selectedCategory
                )
            }
            .onAppear {
                loadFavoriteQuotes()
            }
        }
    }

    private var filterBar: some View {
        FilterBar(selectedCategory: $selectedCategory, categories: Array(Set(viewModel.quotes.map { $0.category })))
    }

    private var filteredQuotes: [Quote] {
        viewModel.quotes.filter { quote in
            selectedCategory == nil || quote.category == selectedCategory
        }
    }

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

    private var quoteListView: some View {
        List {
            ForEach(filteredQuotes) { quote in
                NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: viewModel)) {
                    FavoriteQuoteCardView(quote: quote, unfavoriteAction: {
                        unfavoriteQuote(quote)
                    })
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    unfavoriteSwipeButton(for: quote)
                    editQuoteSwipeButton(for: quote)
                }
            }
        }
    }

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

    private func unfavoriteSwipeButton(for quote: Quote) -> some View {
        Button(action: {
            unfavoriteQuote(quote)
        }) {
            Label("Entfavorisieren", systemImage: "heart.slash")
        }
        .tint(.red)
    }

    private func editQuoteSwipeButton(for quote: Quote) -> some View {
        NavigationLink(destination: AddQuoteView(quoteToEdit: quote)) {
            Button(action: {
                
            }) {
                Label("Bearbeiten", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }

    private func unfavoriteQuote(_ quote: Quote) {
        Task {
            do {
                // Entfernen des Favoriten aus Firebase
                try await viewModel.removeFavoriteQuote(quote)
                // Danach aus der lokalen Liste entfernen
                if let index = viewModel.quotes.firstIndex(where: { $0.id == quote.id }) {
                    viewModel.quotes.remove(at: index)
                }
            } catch {
                viewModel.errorMessage = "Fehler beim Entfernen des Favoriten: \(error.localizedDescription)"
            }
        }
    }

    private func loadFavoriteQuotes() {
        Task {
            do {
                // Favoriten aus Firebase laden
                try await viewModel.loadFavoriteQuotes()
            } catch {
                viewModel.errorMessage = "Fehler beim Laden der Favoriten: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    FavoriteView()
}
