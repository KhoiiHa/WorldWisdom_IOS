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
    @Published var randomQuote: Quote? // Ein zufälliges Zitat
    @Published var errorMessage: String? // Fehlernachricht (z. B. bei Netzwerkfehlern)
    
    private var firebaseManager = FirebaseManager.shared // Zugriff auf den FirebaseManager

    // Lädt mehrere Zitate (z. B. zufällige Zitate)
    func loadMultipleQuotes() async {
        do {
            // Abrufen von mehreren zufälligen Zitaten
            let fetchedQuotes = try await QuoteService.shared.fetchQuotes()
            self.quotes = fetchedQuotes // Zitate zuweisen
        } catch {
            let handledError = QuoteError.handleError(error) // Hier wird der Fehler umgewandelt
            self.errorMessage = handledError.errorDescription
            print("Fehler: \(self.errorMessage ?? "Kein Fehler")")
        }
    }

    // Zitat laden in QuoteViewModel
    func loadRandomQuote() async {
        do {
            // Abrufen eines einzelnen zufälligen Zitats
            let fetchedQuotes = try await QuoteService.shared.fetchQuotes()
            print("Fetched Quotes: \(fetchedQuotes)") // Debugging-Ausgabe
            self.randomQuote = fetchedQuotes.randomElement() // Wählt ein zufälliges Zitat aus der Liste
            print("Random Quote: \(self.randomQuote?.quote ?? "Kein Zitat gefunden")") // Debugging-Ausgabe
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
            print("Fehler beim Laden des Zitats: \(self.errorMessage ?? "Kein Fehler")") // Debugging-Ausgabe
        }
    }

    // Lädt Zitate nach einer Suchanfrage
    func searchQuotes(query: String) async {
        do {
            // Momentan verwenden wir einfach fetchQuotes(), da es keine Suchmöglichkeit gibt.
            let fetchedQuotes = try await QuoteService.shared.fetchQuotes()
            self.quotes = fetchedQuotes // Zitate zuweisen
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
            print("Fehler: \(self.errorMessage ?? "Kein Fehler")")
        }
    }

    // Lädt die Favoriten-Zitate aus Firestore
    func loadFavoriteQuotes() async throws {
        do {
            let fetchedQuotes = try await firebaseManager.fetchFavoriteQuotes() // Fetch ohne optionales Binding
            self.quotes = fetchedQuotes // Setzt die abgerufenen Zitate
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
            throw error // Werfe den Fehler weiter, damit er im catch-Block von FavoriteView gefangen wird
        }
    }
    
    // Funktion zum Aktualisieren des Favoritenstatus eines Zitats
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        // Suchen des Zitats in der Liste
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index].isFavorite = isFavorite
        }
        
        do {
            // Aufruf der Methode aus FirebaseManager zum Aktualisieren des Favoritenstatus
            try await firebaseManager.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
        }
    }
}
