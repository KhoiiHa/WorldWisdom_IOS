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

    init(context: ModelContext) {
        // Hier wird der SwiftDataSyncManager korrekt initialisiert
        self.swiftDataSyncManager = SwiftDataSyncManager(context: context)
    }

    // Lädt einmal ALLE Zitate und speichert sie in quotes
    func loadAllQuotes() async throws {
        do {
            let fetchedQuotes = try await QuoteService.shared.fetchQuotes()
            self.quotes = fetchedQuotes // Speichert ALLE Zitate in der Liste
            // Speichere die Zitate auch lokal in SwiftData
            await syncQuotesWithSwiftData()
        } catch {
            handleError(error) // Fehler direkt behandeln
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
            // Fehlerbehandlung, falls das Synchronisieren fehlschlägt
            handleError(error)
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
            // Entferne Favorit aus Firestore
            await favoriteManager.removeFavoriteQuote(quote)
            // Entferne Favorit aus SwiftData
           try await swiftDataSyncManager.removeFavoriteQuote(quote)
            // Lade die Favoriten neu
            await loadFavoriteQuotes()
        } catch {
            handleError(error) // Fehlerbehandlung
        }
    }

    // Lädt die Favoriten-Zitate aus Firestore und SwiftData
    func loadFavoriteQuotes() async {
        // Lade Favoriten aus Firestore
        await favoriteManager.loadFavoriteQuotes()

        // Lade Favoriten aus SwiftData
        let swiftDataFavorites = await swiftDataSyncManager.fetchFavoriteQuotes()

        // Entferne Duplikate und kombiniere die Favoriten
        var combinedFavorites = favoriteManager.favoriteQuotes + swiftDataFavorites
        combinedFavorites = removeDuplicateQuotes(from: combinedFavorites)

        self.favoriteQuotes = combinedFavorites
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
            // Favorit in Firestore speichern
            await favoriteManager.addFavoriteQuote(quote)
            // Favorit in SwiftData speichern
            try await swiftDataSyncManager.addFavoriteQuote(quote)
            // Favorit zum lokalen Array hinzufügen
            self.favoriteQuotes.append(quote)
        } catch {
            handleError(error) // Fehlerbehandlung
        }
    }

    // Aktualisiert den Favoritenstatus eines Zitats in Firestore und SwiftData
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        do {
            await favoriteManager.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
            try await swiftDataSyncManager.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
        } catch {
            handleError(error) // Fehlerbehandlung
        }
    }

    // Löscht ein Zitat aus der lokalen Liste, aus Firestore und aus SwiftData
    func deleteQuote(_ quote: Quote) async throws {
        do {
            // Zitat aus Firestore und SwiftData löschen
            try await firebaseManager.deleteQuote(quote)
            try await swiftDataSyncManager.deleteQuote(quote)
            // Zitat aus der lokalen Liste entfernen
            if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
                quotes.remove(at: index)
            }
        } catch {
            handleError(error) // Fehlerbehandlung
            throw error // Fehler weiterwerfen
        }
    }
    
    // Fügt ein neues Zitat hinzu und speichert es sowohl in Firestore als auch in SwiftData
    func addQuote(_ quote: Quote) async throws {
        // Überprüfen, ob das Zitat korrekt zur lokalen Liste hinzugefügt wird
        print("Zitat wird lokal hinzugefügt: \(quote)")
        quotes.append(quote) // Hinzufügen des Zitats zur lokalen Liste

        do {
            // Speichern des Zitats in Firestore
            print("Versuche, Zitat in Firestore zu speichern...")
            try await firebaseManager.saveUserQuote(quoteText: quote.quote, author: quote.author)
            print("Zitat erfolgreich in Firestore gespeichert!")

            // Speichern des Zitats in SwiftData
            try await swiftDataSyncManager.addQuote(quote)
        } catch {
            print("Fehler beim Speichern des Zitats in Firestore: \(error.localizedDescription)")
            handleError(error)  // Fehlerbehandlung
            throw error  // Fehler weiterwerfen
        }
    }

    // Speichert das bearbeitete Zitat sowohl in Firestore als auch in SwiftData
    func saveEditedQuote(_ quote: Quote) async throws {
        // Update der lokalen Liste
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index] = quote // Überschreibt das Zitat in der Liste
        }
        
        do {
            // Update in Firestore
            try await firebaseManager.updateQuote(quote)
            // Update in SwiftData
            await swiftDataSyncManager.updateQuote(quote)
        } catch {
            handleError(error) // Fehlerbehandlung
            throw error
        }
    }

    // Gemeinsame Fehlerbehandlung
    private func handleError(_ error: Error) {
        let handledError = QuoteError.handleError(error)
        self.errorMessage = handledError.errorDescription
        self.recoverySuggestion = handledError.recoverySuggestion
        self.hasError = true
        print("Fehler: \(self.errorMessage ?? "Kein Fehler")")
        print("Vorschlag zur Fehlerbehebung: \(self.recoverySuggestion ?? "Kein Vorschlag")")
    }
}

