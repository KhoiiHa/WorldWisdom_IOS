//
//  QuoteViewModel.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 27.01.25.
//

import Foundation
import FirebaseFirestore
import Firebase
import SwiftData
import Reachability

/// ViewModel für die Verwaltung und Anzeige von Zitaten, inkl. Offline-Unterstützung, Fehlerbehandlung und Favoritenlogik

// MARK: - QuoteViewModel
@MainActor
class QuoteViewModel: ObservableObject {
    // MARK: - Veröffentlichte Eigenschaften
    @Published var quotes: [Quote] = [] // Alle Zitate
    @Published var randomQuote: Quote?
    @Published var favoriteQuotes: [Quote] = []
    @Published var errorMessage: String?
    @Published var recoverySuggestion: String?
    @Published var hasError: Bool = false
    
    private var firebaseManager = FirebaseManager.shared
    private let favoriteManager = FavoriteManager.shared

    // SwiftData Manager für lokale Speicherung
    private var swiftDataSyncManager: SwiftDataSyncManager
    private var reachability: Reachability? // Reachability-Instanz zum Überprüfen der Netzwerkkonnektivität

    // MARK: - Initialisierung
    init() {
        self.swiftDataSyncManager = SwiftDataSyncManager()
        self.reachability = try? Reachability() // Initialisiere Reachability
    }

    // MARK: - Netzwerkprüfung
    // Prüft, ob eine Internetverbindung vorhanden ist
    func isConnectedToInternet() -> Bool {
        return reachability?.connection != .unavailable
    }

    // MARK: - Zitate laden
    // Lädt einmal ALLE Zitate und speichert sie in quotes
    func loadAllQuotes() async throws {
        do {
            if isConnectedToInternet() {
                // Zitate von der API abrufen
                var fetchedQuotes = try await QuoteService.shared.fetchQuotes()

                // Hier sicherstellen, dass jedes Zitat die authorImageURL enthält
                for index in fetchedQuotes.indices {
                    let quote = fetchedQuotes[index]
                    if quote.authorImageURLs?.first == nil || quote.authorImageURLs?.first?.isEmpty == true {
                        // Setze die Platzhalter-URL von Cloudinary
                        fetchedQuotes[index].authorImageURLs = ["https://res.cloudinary.com/dpaehynl2/image/upload/v1739866635/cld-sample-4.jpg"]
                    }
                }

                self.quotes = fetchedQuotes // Speichert ALLE Zitate in der Liste
                await syncQuotesWithSwiftData()
            } else {
                // Zitate aus SwiftData abrufen, wenn keine Internetverbindung besteht
                await fetchQuotesFromSwiftData()
            }
        } catch {
            print("⚠️ Fehler beim Laden über API – Fallback wird geladen.")
            let fallbackQuotes = loadQuotesFromFallback()
            self.quotes = fallbackQuotes
        }
    }

    private func loadQuotesFromFallback() -> [Quote] {
        guard let url = Bundle.main.url(forResource: "QuotesFallback", withExtension: "json") else {
            print("❌ Fallback-Datei nicht gefunden.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([Quote].self, from: data)
        } catch {
            print("❌ Fehler beim Laden der Fallback-Quotes: \(error)")
            return []
        }
    }

    // MARK: - Synchronisation mit SwiftData
    // Synchronisiert die Zitate zwischen Firebase und SwiftData
    private func syncQuotesWithSwiftData() async {
        do {
            for quote in quotes {
                try await swiftDataSyncManager.addQuote(quote) // Synchronisieren mit SwiftData
            }
        } catch {
            self.handleError(error)
        }
    }

    // MARK: - Lokale Zitate abrufen
    // Lädt Zitate aus SwiftData (Offline-Modus)
    private func fetchQuotesFromSwiftData() async {
        do {
            let fetchRequest = FetchDescriptor<QuoteEntity>()
            // fetch ist synchron, daher KEIN await verwenden
            let quoteEntities = try swiftDataSyncManager.context.fetch(fetchRequest)

            // Verwende TaskGroup, um gleichzeitig auf alle Zitate zuzugreifen
            let localQuotes = try await withThrowingTaskGroup(of: Quote.self) { group in
                for quoteEntity in quoteEntities {
                    // Kapsle jedes QuoteEntity in einen Actor
                    let actor = QuoteEntityActor(quoteEntity: quoteEntity)

                    group.addTask {
                        // Verwende den Actor, um sicher auf die Daten zuzugreifen
                        let tags = await actor.getTags()
                        let authorImageURL = await actor.getAuthorImageURL()

                        // Return das Quote-Objekt ohne QuoteEntity (nur notwendige Daten)
                        return Quote(
                            id: quoteEntity.id,
                            author: quoteEntity.author,
                            quote: quoteEntity.quoteText,
                            category: quoteEntity.category,
                            tags: tags,
                            isFavorite: quoteEntity.isFavorite,
                            description: quoteEntity.quoteDescription,
                            source: quoteEntity.source,
                            authorImageURLs: [authorImageURL]
                        )
                    }
                }

                // Sammle die Ergebnisse aus der TaskGroup
                var localQuotes: [Quote] = []
                for try await quote in group {
                    localQuotes.append(quote)
                }
                return localQuotes
            }

            // Speichern der Zitate in der ViewModel-Liste
            self.quotes = localQuotes
        } catch {
            self.handleError(error)
        }
    }

    // MARK: - Actor für sicheren Datenzugriff
    // Actor, der den Zugriff auf QuoteEntity kapselt
    actor QuoteEntityActor {
        private let quoteEntity: QuoteEntity
        
        // Initializer für den Actor
        init(quoteEntity: QuoteEntity) {
            self.quoteEntity = quoteEntity
        }
        
        // Methoden zum sicheren Zugriff auf die Daten
        func getTags() -> [String] {
            return quoteEntity.tags
        }
        
        func getAuthorImageURL() -> String {
            return quoteEntity.authorImageURLs.first ?? ""
        }
    }

    // MARK: - Fehlerbehandlung
    // Gemeinsame Fehlerbehandlung
    private func handleError(_ error: Error) {
        // Fehlerbehandlung für QuoteError
        if let quoteError = error as? QuoteError {
            self.errorMessage = quoteError.errorDescription
            self.recoverySuggestion = quoteError.recoverySuggestion
        }
        // Fehlerbehandlung für SwiftDataError
        else if let swiftDataError = error as? SwiftDataError {
            self.errorMessage = swiftDataError.errorDescription
            self.recoverySuggestion = swiftDataError.recoverySuggestion
        }
        // Fehlerbehandlung für FavoriteError
        else if let favoriteError = error as? FavoriteError {
            self.errorMessage = favoriteError.errorMessage
            self.recoverySuggestion = favoriteError.errorMessage
        }
        // Unbekannter Fehler
        else {
            self.errorMessage = "Unbekannter Fehler: \(error.localizedDescription)"
            self.recoverySuggestion = "Versuche es später erneut."
        }
        
        self.hasError = true
        print("Fehler: \(self.errorMessage ?? "Kein Fehler")")
        print("Vorschlag zur Fehlerbehebung: \(self.recoverySuggestion ?? "Kein Vorschlag")")
    }
    
    // MARK: - Favoritenstatus aktualisieren
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        do {
            // Schritt 1: Favoritenstatus lokal ändern
            if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
                quotes[index].isFavorite = isFavorite
            }

            // Schritt 2: In Firestore aktualisieren
            if isFavorite {
                try await favoriteManager.addFavoriteQuote(quote)
            } else {
                try await favoriteManager.removeFavoriteQuote(quote)
            }

            // Schritt 3: In SwiftData aktualisieren
            try await swiftDataSyncManager.updateFavoriteStatus(for: quote, to: isFavorite)
        } catch {
            self.handleError(error)
        }
    }
    
    // MARK: - Zufälliges Zitat auswählen
    func getRandomQuote() async {
        if quotes.isEmpty {
            if isConnectedToInternet() {
                do {
                    try await loadAllQuotes()
                } catch {
                    self.handleError(error)
                }
            } else {
                await fetchQuotesFromSwiftData()
            }
        }

        if !quotes.isEmpty {
            randomQuote = quotes.randomElement()
        } else {
            errorMessage = "Keine Zitate verfügbar."
        }
    }
}
