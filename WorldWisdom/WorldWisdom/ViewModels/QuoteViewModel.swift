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
    @Published var favoriteQuotes: [Quote] = []
    @Published var errorMessage: String?
    @Published var recoverySuggestion: String? // Vorschläge zur Fehlerbehebung
    @Published var hasError: Bool = false
    
    private var firebaseManager = FirebaseManager.shared
    private let favoriteManager = FavoriteManager()


    // Lädt einmal ALLE Zitate und speichert sie in quotes
    func loadAllQuotes() async throws {
        do {
            let fetchedQuotes = try await QuoteService.shared.fetchQuotes()
            self.quotes = fetchedQuotes // Speichert ALLE Zitate in der Liste
        } catch {
            throw error // Fehler weiterwerfen, damit der Aufrufer (z.B. HomeView) damit umgehen kann
        }
    }

    // Gibt ein zufälliges Zitat aus
    func getRandomQuote() {
        guard !quotes.isEmpty else {
            self.randomQuote = nil
            return
        }
        self.randomQuote = quotes.randomElement()
    }

    // Entfernt ein Zitat aus den Favoriten in Firestore
    func removeFavoriteQuote(_ quote: Quote) async {
        await favoriteManager.removeFavoriteQuote(quote)
        await loadFavoriteQuotes() // Lädt die Favoriten neu
    }

    // Lädt die Favoriten-Zitate aus Firestore
    func loadFavoriteQuotes() async {
        await favoriteManager.loadFavoriteQuotes()
        self.favoriteQuotes = favoriteManager.favoriteQuotes
    }

    // Funktion zum Hinzufügen eines Zitats als Favorit
    func addFavoriteQuote(_ quote: Quote) async {
        await favoriteManager.addFavoriteQuote(quote)
        self.favoriteQuotes.append(quote)  // Direktes Hinzufügen zum lokalen Array
    }

    // Aktualisiert den Favoritenstatus eines Zitats
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        await favoriteManager.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
    }

    // Löscht ein Zitat aus der lokalen Liste und aus Firestore
    func deleteQuote(_ quote: Quote) async throws {
        // Zitat aus der lokalen Liste entfernen
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes.remove(at: index)
        }
        
        // Zitat aus Firestore löschen
        do {
            try await firebaseManager.deleteQuote(quote)
        } catch {
            handleError(error)
            throw error
        }
    }
    
    // Fügt ein neues Zitat hinzu
    func addQuote(_ quote: Quote) async throws {
        // Überprüfen, ob das Zitat korrekt zur lokalen Liste hinzugefügt wird
        print("Zitat wird lokal hinzugefügt: \(quote)")
        quotes.append(quote) // Hinzufügen des Zitats zur lokalen Liste

        // Überprüfen, ob das Zitat korrekt in Firestore gespeichert wird
        do {
            print("Versuche, Zitat in Firestore zu speichern...")
            try await firebaseManager.saveUserQuote(quoteText: quote.quote, author: quote.author)
            print("Zitat erfolgreich in Firestore gespeichert!")
        } catch {
            print("Fehler beim Speichern des Zitats in Firestore: \(error.localizedDescription)")
            handleError(error)  // Fehlerbehandlung
            throw error  // Fehler weiterwerfen
        }
    }

    // Speichert das bearbeitete Zitat
    func saveEditedQuote(_ quote: Quote) async throws {
        // Update der lokalen Liste
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index] = quote // Überschreibt das Zitat in der Liste
        }
        
        // Update in Firestore
        do {
            try await firebaseManager.updateQuote(quote)
        } catch {
            handleError(error)
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
