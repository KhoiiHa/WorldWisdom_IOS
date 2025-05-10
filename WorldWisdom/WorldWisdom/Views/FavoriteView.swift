//
//  FavoriteView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct FavoriteView: View {
    @EnvironmentObject var favoriteManager: FavoriteManager
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @StateObject private var quoteViewModel = QuoteViewModel()
    @State private var selectedCategory: String = "Alle"

    var body: some View {
        NavigationStack {
            VStack {
                let allCategories = ["Alle"] + Array(Set(favoriteManager.favoriteQuotes.map { $0.category })).sorted()
                
                Picker("Kategorie", selection: $selectedCategory) {
                    ForEach(allCategories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                let sortedQuotes = favoriteManager.favoriteQuotes
                let filteredQuotes = sortedQuotes.filter {
                    selectedCategory == "Alle" || $0.category == selectedCategory
                }
                
                List {
                    if filteredQuotes.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(filteredQuotes) { quote in
                            FavoriteQuoteCardView(quote: quote)
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
                .navigationTitle("Meine Favoriten")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: AddQuoteView(quoteToEdit: nil)) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await favoriteManager.removeAllFavorites()
                                } catch {
                                    showErrorMessage = true
                                    errorMessage = "Favoriten konnten nicht gelöscht werden."
                                    print("Fehler beim Löschen aller Favoriten: \(error.localizedDescription)")
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                .task {
                    await favoriteManager.loadFavoriteQuotes()
                }

                // Erfolgsnachricht (klassische Anzeige) wird hier angezeigt, wenn vorhanden
                if let successMessage = successMessage {
                    Text(successMessage)
                        .font(.subheadline)  // Kleinere Schriftgröße
                        .foregroundColor(.green)  // Dezente Farbe
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .transition(.opacity)  // Einfache Übergangsanime
                        .animation(.easeInOut, value: successMessage)
                }
            }
            .alert(isPresented: $showErrorMessage) {
                Alert(title: Text("Fehler"), message: Text(errorMessage ?? "Unbekannter Fehler"), dismissButton: .default(Text("OK")))
            }
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
            // Favoriten entfernen
            try await favoriteManager.removeFavoriteQuote(quote)
            showErrorMessage = false  // Fehleranzeige zurücksetzen

            // Erfolgsmeldung setzen
            successMessage = "Zitat erfolgreich entfernt."

            // Erfolgsmeldung nach 2 Sekunden ausblenden
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                successMessage = nil
            }

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
