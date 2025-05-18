//
//  FavoriteView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI


/// Zeigt die gespeicherten Favoriten des Nutzers an, inkl. Kategoriefilter, Swipe-to-Delete und Gesamtlöschung.

struct FavoriteView: View {
    @EnvironmentObject var favoriteManager: FavoriteManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @StateObject private var quoteViewModel = QuoteViewModel()
    @State private var selectedCategory: String = "Alle"
    @State private var selectedQuote: Quote?

    // MARK: - Kategorien für den Filter
    private var allCategories: [String] {
        ["Alle"] + Array(Set(favoriteManager.favoriteQuotes.map { $0.category })).sorted()
    }

    // MARK: - Favoriten sortiert nach Autor
    private var sortedQuotes: [Quote] {
        favoriteManager.favoriteQuotes.sorted(by: { $0.author < $1.author })
    }

    // MARK: - Gefilterte Favoriten nach ausgewählter Kategorie
    private var filteredQuotes: [Quote] {
        sortedQuotes.filter {
            selectedCategory == "Alle" || $0.category == selectedCategory
        }
    }

    // MARK: - View Body
    var body: some View {
        NavigationStack {
            VStack {
                // Kategorie Picker mit Segment-Stil
                Picker("Kategorie", selection: $selectedCategory) {
                    ForEach(allCategories, id: \.self) { category in
                        Text(category)
                            .foregroundColor(Color("primaryText"))
                            .tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("cardBackground"))
                        .shadow(color: Color("buttonColor").opacity(0.05), radius: 3, x: 0, y: 1)
                )
                .cornerRadius(10)
                .padding(.horizontal)
                
                if !networkMonitor.isConnected {
                    Text("⚠️ Offline-Modus – Favoriten werden lokal angezeigt")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                
                // Liste der Favoriten
                List {
                    if filteredQuotes.isEmpty {
                        emptyStateView
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredQuotes) { quote in
                            FavoriteQuoteCardView(quote: quote)
                                .foregroundColor(Color("primaryText"))
                                .padding(.vertical, 4)
                                .listRowBackground(Color("cardBackground"))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task {
                                            await removeFavorite(quote)
                                        }
                                    } label: {
                                        Label("Entfernen", systemImage: "trash.fill")
                                    }
                                }
                                .onTapGesture {
                                    selectedQuote = quote
                                }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Meine Favoriten")
                .toolbar {
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
                                .foregroundColor(.red)
                                .padding(6)
                                .background(Circle().fill(Color("cardBackground")))
                        }
                    }
                }
                .task {
                    await favoriteManager.loadFavoriteQuotes()
                }

                // MARK: - Erfolgsnachricht anzeigen, wenn vorhanden
                if let successMessage = successMessage {
                    Text(successMessage)
                        .font(.subheadline)  // Kleinere Schriftgröße
                        .foregroundColor(Color("mainBlue"))  // Dezente Farbe
                        .padding(8)
                        .background(Color("mainBlue").opacity(0.1))
                        .cornerRadius(10)
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
            .background(Color("background").ignoresSafeArea())
            .navigationDestination(item: $selectedQuote) { quote in
                AutorDetailView(authorName: quote.author, selectedQuoteText: quote.quote)
                    .environmentObject(networkMonitor)
            }
        }
    }

    // MARK: - Leerer Zustand, wenn keine Favoriten vorhanden sind
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "star.slash")
                .font(.system(size: 50))
                .foregroundColor(Color("secondaryText"))
            Text("Noch keine Favoriten gespeichert.")
                .font(.headline)
                .foregroundColor(Color("secondaryText"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }

    // MARK: - Favoriten entfernen
    /// Entfernt ein Favoriten-Zitat und zeigt gegebenenfalls eine Erfolgsmeldung oder Fehler an.
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
