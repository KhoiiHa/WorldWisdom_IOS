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
    @Published var quotes: [Quote] = [] // Alle Zitate
    @Published var randomQuote: Quote?
    @Published var errorMessage: String? // Fehlernachricht
    
    private var firebaseManager = FirebaseManager.shared // Zugriff auf Firebase

    // Lädt einmal ALLE Zitate und speichert sie in quotes
    func loadAllQuotes() async {
        do {
            let fetchedQuotes = try await QuoteService.shared.fetchQuotes()
            self.quotes = fetchedQuotes // Speichert ALLE Zitate in der Liste
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
            print("Fehler: \(self.errorMessage ?? "Kein Fehler")")
        }
    }

    // Gibt ein zufälliges Zitat aus der bereits geladenen Liste zurück
    func getRandomQuote() {
        self.randomQuote = quotes.randomElement()
    }

    // Filtert Zitate nach einer Suchanfrage
    func searchQuotes(query: String) -> [Quote] {
        return quotes.filter { $0.quote.contains(query) || $0.author.contains(query) }
    }

    // Gibt alle Zitate eines bestimmten Autors zurück
    func getQuotesByAuthor(author: String) -> [Quote] {
        return quotes.filter { $0.author == author }
    }

    // Gibt alle Zitate einer bestimmten Kategorie zurück
    func getQuotesByCategory(category: String) -> [Quote] {
        return quotes.filter { $0.category == category }
    }
    
    // **NEU: Suchfunktion für Autoren**
    func searchAuthors(query: String) -> [Quote] {
        guard !query.isEmpty else { return [] }
        return quotes.filter { $0.author.lowercased().contains(query.lowercased()) }
    }

    // Lädt die Favoriten-Zitate aus Firestore
    func loadFavoriteQuotes() async throws {
        do {
            let fetchedQuotes = try await firebaseManager.fetchFavoriteQuotes()
            self.quotes = fetchedQuotes // Speichert die abgerufenen Favoriten in quotes
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
            throw error
        }
    }
    
    // Aktualisiert den Favoritenstatus eines Zitats
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) { 
            quotes[index].isFavorite = isFavorite
        }
        
        do {
            try await firebaseManager.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
        }
    }

    // Entfernt ein Zitat aus den Favoriten in Firestore
    func removeFavoriteQuote(_ quote: Quote) async throws {
        do {
            // Verwende FirebaseManager, um das Zitat aus der Datenbank zu löschen
            try await firebaseManager.deleteFavoriteQuote(quote)
            
            // Erfolgreiches Löschen, optional kann man auch noch die Liste aktualisieren
        } catch {
            // Fehlerbehandlung, falls das Löschen fehlschlägt
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
            throw error
        }
    }
    
    // Funktion zum Löschen eines Zitats
    func deleteQuote(_ quote: Quote) async throws {
        // Zitat aus der lokalen Liste entfernen
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes.remove(at: index)
        }
        
        // Zitat aus Firestore löschen (falls verwendet)
        do {
            try await firebaseManager.deleteQuote(quote)
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
            throw error
        }
    }
    
    // Funktion zum Speichern eines bearbeiteten Zitats
    func saveEditedQuote(_ quote: Quote) async throws {
        // Update der lokalen Liste
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index] = quote // Überschreibt das Zitat in der Liste
        }
        
        // Update in Firestore
        do {
            try await firebaseManager.updateQuote(quote) 
        } catch {
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
            throw error
        }
    }
    
    // Beispiel für das Hinzufügen eines Zitats
    func addFavoriteQuote(_ quote: Quote) async throws {
        do {
            // Zitat in Firebase speichern
            try await firebaseManager.addFavoriteQuote(quote)
            
            // Zitat zur lokalen Liste hinzufügen
            self.quotes.append(quote) // Hier wird das neue Zitat zur Liste hinzugefügt
        } catch {
            // Fehlerbehandlung
            let handledError = QuoteError.handleError(error)
            self.errorMessage = handledError.errorDescription
        }
    }
}
