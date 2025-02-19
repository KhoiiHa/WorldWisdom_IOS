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

@MainActor
class QuoteViewModel: ObservableObject {
    @Published var quotes: [Quote] = [] // Alle Zitate
    @Published var randomQuote: Quote?
    @Published var favoriteQuotes: [Quote] = []
    @Published var errorMessage: String?
    @Published var recoverySuggestion: String? // Vorschläge zur Fehlerbehebung
    @Published var hasError: Bool = false
    
    private var firebaseManager = FirebaseManager.shared
    private let favoriteManager = FavoriteManager()

    // SwiftData Manager für lokale Speicherung
    private var swiftDataSyncManager: SwiftDataSyncManager
    private var reachability: Reachability? // Reachability-Instanz zum Überprüfen der Netzwerkkonnektivität

    init() {
        self.swiftDataSyncManager = SwiftDataSyncManager()
        self.reachability = try? Reachability() // Initialisiere Reachability
    }

    // Prüft, ob eine Internetverbindung vorhanden ist
    func isConnectedToInternet() -> Bool {
        return reachability?.connection != .unavailable
    }

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
            self.handleError(error) // Fehler direkt behandeln
            throw error // Fehler weiterwerfen
        }
    }

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

    // Lädt Zitate aus SwiftData (Offline-Modus)
    private func fetchQuotesFromSwiftData() async {
        do {
            let fetchRequest = FetchDescriptor<QuoteEntity>()
            let quoteEntities = try await Task {
                return try swiftDataSyncManager.context.fetch(fetchRequest)
            }.value
            
            let localQuotes = quoteEntities.map { quoteEntity in
                // Extrahiere die Bild-URL (falls vorhanden) für den Autor
                let authorImageURL = quoteEntity.authorImageURLs?.first ?? ""
                
                // Optional entpacken, falls tags nil ist, dann leeres Array verwenden
                let tags = quoteEntity.tags ?? []
                
                return Quote(
                    id: quoteEntity.id,
                    author: quoteEntity.author,
                    quote: quoteEntity.quote,
                    category: quoteEntity.category,
                    tags: tags,
                    isFavorite: quoteEntity.isFavorite,
                    description: quoteEntity.quoteDescription,
                    source: quoteEntity.source,
                    authorImageURLs: [authorImageURL]
                )
            }
            
            self.quotes = localQuotes
        } catch {
            self.handleError(error)
        }
    }
    
    
    // Gibt ein zufälliges Zitat aus
    func getRandomQuote() {
        guard let randomQuote = quotes.randomElement() else {
            self.randomQuote = nil
            return
        }
        self.randomQuote = randomQuote
    }

    // Entfernt ein Zitat aus den Favoriten in Firestore und SwiftData
    func removeFavoriteQuote(_ quote: Quote) async {
        do {
            try await favoriteManager.removeFavoriteQuote(quote)
            try await swiftDataSyncManager.removeFavoriteQuote(quote)
            await loadFavoriteQuotes()
        } catch {
            self.handleError(error)
        }
    }

    // Lädt die Favoriten-Zitate aus Firestore und SwiftData
    func loadFavoriteQuotes() async {
        do {
            await favoriteManager.loadFavoriteQuotes()
            let swiftDataFavorites = try await swiftDataSyncManager.fetchFavoriteQuotes()
            var combinedFavorites = favoriteManager.favoriteQuotes + swiftDataFavorites
            combinedFavorites = removeDuplicateQuotes(from: combinedFavorites)
            self.favoriteQuotes = combinedFavorites
        } catch {
            self.handleError(error)
        }
    }

    // Methode zum Entfernen von Duplikaten basierend auf der ID
    func removeDuplicateQuotes(from quotes: [Quote]) -> [Quote] {
        var uniqueQuotes: [Quote] = []
        for quote in quotes {
            if !uniqueQuotes.contains(where: { $0.id == quote.id }) {
                uniqueQuotes.append(quote)
            }
        }
        return uniqueQuotes
    }

    // Funktion zum Hinzufügen eines Zitats als Favorit (sowohl in Firestore als auch in SwiftData)
    func addFavoriteQuote(_ quote: Quote) async {
        do {
            // Zuerst in Firestore aktualisieren
            await favoriteManager.updateFavoriteStatus(for: quote, isFavorite: true)
            
            // Dann in SwiftData den Favoritenstatus aktualisieren
            try await swiftDataSyncManager.updateFavoriteStatus(for: quote, to: true)
            
            // Favoritenliste im ViewModel aktualisieren
            self.favoriteQuotes.append(quote)
        } catch {
            self.handleError(error)
        }
    }

    // Aktualisiert den Favoritenstatus eines Zitats in Firestore und SwiftData
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        do {
            await favoriteManager.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
            try await swiftDataSyncManager.updateFavoriteStatus(for: quote, to: isFavorite)
        } catch {
            self.handleError(error)
        }
    }

    // Löscht ein Zitat aus der lokalen Liste, aus Firestore und aus SwiftData
    func deleteQuote(_ quote: Quote) async throws {
        do {
            try await firebaseManager.deleteQuote(quote)
            try await swiftDataSyncManager.deleteQuote(quote)
            if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
                quotes.remove(at: index)
            }
        } catch {
            self.handleError(error)
            throw error
        }
    }

    // Fügt ein neues Zitat hinzu und speichert es sowohl in Firestore als auch in SwiftData
    func addQuote(_ quote: Quote) async throws {
        quotes.append(quote)
        do {
            // Überprüfe, ob authorImageURLs nicht leer ist
            if let authorImageURL = quote.authorImageURLs?.first, !authorImageURL.isEmpty {
                // Übergebe den ersten Wert aus dem Array authorImageURLs
                try await firebaseManager.saveUserQuote(
                    quoteText: quote.quote,
                    author: quote.author,
                    authorImageURL: authorImageURL
                )
            } else {
                try await firebaseManager.saveUserQuote(
                    quoteText: quote.quote,
                    author: quote.author,
                    authorImageURL: "" // Leerer String oder Standardwert
                )
            }

            try await swiftDataSyncManager.addQuote(quote)
        } catch {
            print("Fehler beim Speichern des Zitats in Firestore: \(error.localizedDescription)")
            self.handleError(error)
            throw error
        }
    }

    // Speichert das bearbeitete Zitat sowohl in Firestore als auch in SwiftData
    func saveEditedQuote(_ quote: Quote) async throws {
        let quoteEntity = QuoteEntity(
            id: quote.id,
            author: quote.author,
            quote: quote.quote,
            category: quote.category,
            tags: quote.tags,
            isFavorite: quote.isFavorite,
            quoteDescription: quote.description,
            source: quote.source,
            authorImageURLs: quote.authorImageURLs,
            authorImageData: nil // falls du es später hinzufügst
        )

        do {
            // Versuche, das Zitat in Firestore zu aktualisieren (falls benötigt)
            try await firebaseManager.updateQuote(quote)

            // Speichere oder aktualisiere das Zitat in SwiftData
            swiftDataSyncManager.addOrUpdateQuote(quoteEntity)
        } catch {
            self.handleError(error)
            throw error
        }
    }

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
            self.recoverySuggestion = favoriteError.errorMessage // Gleich wie die Fehlermeldung
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
}
