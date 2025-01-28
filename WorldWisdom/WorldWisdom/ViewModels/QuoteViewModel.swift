//
//  QuoteViewModel.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 27.01.25.
//

import Foundation
import FirebaseFirestore
import Firebase

@MainActor
class QuoteViewModel: ObservableObject {
    @Published var quotes: [Quote] = [] // Alle Zitate, die abgerufen wurden
    @Published var categories: [String] = [] // Kategorien, die abgerufen wurden
    @Published var errorMessage: String? // Fehlernachricht (z. B. bei Netzwerkfehlern)
    
    private var firebaseManager = FirebaseManager.shared // Zugriff auf den FirebaseManager
    
    private var database = Firestore.firestore()

    // Lädt mehrere Zitate (z. B. zufällige Zitate)
    func loadMultipleQuotes() async {
        do {
            // Abrufen von mehreren zufälligen Zitaten
            let fetchedQuotes = try await QuoteService.shared.fetchMultipleQuotes()
            self.quotes = fetchedQuotes // Zitate zuweisen
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
        }
    }

    // Lädt ein zufälliges Zitat
    func loadRandomQuote() async {
        do {
            // Abrufen eines einzelnen zufälligen Zitats
            let fetchedQuote = try await QuoteService.shared.fetchRandomQuote()
            self.quotes = [fetchedQuote] // Nur das zufällige Zitat anzeigen
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
        }
    }

    // Lädt Zitate nach Kategorie
    func loadQuotesByCategory(category: String) async {
        do {
            // Abrufen von Zitaten nach einer bestimmten Kategorie
            let fetchedQuotes = try await QuoteService.shared.fetchQuotesByCategory(category: category)
            self.quotes = fetchedQuotes // Zitate zuweisen
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
        }
    }

    // Lädt Zitate durch eine Suchanfrage
    func searchQuotes(query: String) async throws {
        do {
            // Abrufen von Zitaten, die der Suchanfrage entsprechen
            let fetchedQuotes = try await QuoteService.shared.searchQuotes(query: query)
            self.quotes = fetchedQuotes // Zitate zuweisen
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
            throw error // Fehler weiterwerfen
        }
    }

    // Lädt Zitate von einem bestimmten Autor
    func loadQuotesByAuthor(author: String) async {
        do {
            // Abrufen von Zitaten eines bestimmten Autors
            let fetchedQuotes = try await QuoteService.shared.fetchAuthorQuotes(authorName: author)
            self.quotes = fetchedQuotes // Zitate zuweisen
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
        }
    }

    // Lädt alle Kategorien
    func loadCategories() async {
        do {
            // Hier holen wir die Kategorien von der API
            let fetchedCategories = try await QuoteService.shared.fetchCategories()
            self.categories = fetchedCategories // Kategorien speichern
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
        }
    }
    
    // Lädt die Favoriten-Zitate aus Firestore
    func loadFavoriteQuotes() async throws { // Wirf einen Fehler, falls etwas schiefgeht
        do {
            if let fetchedQuotes = try await firebaseManager.fetchFavoriteQuotes() {
                self.quotes = fetchedQuotes // Setzt die abgerufenen Zitate
            }
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
            throw error // Werfe den Fehler weiter, damit er im catch-Block von FavoriteView gefangen wird
        }
    }
    
    // Funktion zum Aktualisieren des Favoritenstatus eines Zitats
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) {
        // Suchen des Zitats in der Liste
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index].isFavorite = isFavorite
        }
        
        // Aktualisieren des Favoritenstatus in Firestore
        Task {
            do {
                // Aufruf der Methode aus FirebaseManager
                try await firebaseManager.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
            } catch {
                let handledError = QuoteError.handleError(error)
                self.errorMessage = handledError.errorDescription
            }
        }
    }
}
