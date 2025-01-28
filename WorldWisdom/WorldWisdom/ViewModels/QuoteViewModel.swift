//
//  QuoteViewModel.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 27.01.25.
//

import Foundation
import FirebaseFirestore

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
        } catch let error as NSError {
            // Fehlerbehandlung mit Firebase-spezifischen Fehlern
            self.errorMessage = AuthError.handleFirebaseError(error)
        } catch {
            self.errorMessage = "Fehler beim Laden der Zitate: \(error.localizedDescription)"
        }
    }

    // Lädt ein zufälliges Zitat
    func loadRandomQuote() async {
        do {
            // Abrufen eines einzelnen zufälligen Zitats
            let fetchedQuote = try await QuoteService.shared.fetchRandomQuote()
            self.quotes = [fetchedQuote] // Nur das zufällige Zitat anzeigen
        } catch let error as NSError {
            // Fehlerbehandlung mit Firebase-spezifischen Fehlern
            self.errorMessage = AuthError.handleFirebaseError(error)
        } catch {
            self.errorMessage = "Fehler beim Laden des Zitats: \(error.localizedDescription)"
        }
    }

    // Lädt Zitate nach Kategorie
    func loadQuotesByCategory(category: String) async {
        do {
            // Abrufen von Zitaten nach einer bestimmten Kategorie
            let fetchedQuotes = try await QuoteService.shared.fetchQuotesByCategory(category: category)
            self.quotes = fetchedQuotes // Zitate zuweisen
        } catch let error as NSError {
            // Fehlerbehandlung mit Firebase-spezifischen Fehlern
            self.errorMessage = AuthError.handleFirebaseError(error)
        } catch {
            self.errorMessage = "Fehler beim Laden der Zitate: \(error.localizedDescription)"
        }
    }

    // Lädt Zitate durch eine Suchanfrage (mit async und throws)
    func searchQuotes(query: String) async throws {
        do {
            // Abrufen von Zitaten, die der Suchanfrage entsprechen
            let fetchedQuotes = try await QuoteService.shared.searchQuotes(query: query)
            self.quotes = fetchedQuotes // Zitate zuweisen
        } catch let error as NSError {
            // Fehlerbehandlung mit Firebase-spezifischen Fehlern
            self.errorMessage = AuthError.handleFirebaseError(error)
            throw error // Fehler weiterwerfen
        } catch {
            self.errorMessage = "Fehler bei der Suche: \(error.localizedDescription)"
            throw error // Fehler weiterwerfen
        }
    }

    // Lädt Zitate von einem bestimmten Autor
    func loadQuotesByAuthor(author: String) async {
        do {
            // Abrufen von Zitaten eines bestimmten Autors
            let fetchedQuotes = try await QuoteService.shared.fetchAuthorQuotes(authorName: author)
            self.quotes = fetchedQuotes // Zitate zuweisen
        } catch let error as NSError {
            // Fehlerbehandlung mit Firebase-spezifischen Fehlern
            self.errorMessage = AuthError.handleFirebaseError(error)
        } catch {
            self.errorMessage = "Fehler beim Laden der Zitate von \(author): \(error.localizedDescription)"
        }
    }

    // Lädt alle Kategorien
    func loadCategories() async {
        do {
            // Hier holen wir die Kategorien von der API
            let fetchedCategories = try await QuoteService.shared.fetchCategories()
            self.categories = fetchedCategories // Kategorien speichern
        } catch let error as NSError {
            self.errorMessage = AuthError.handleFirebaseError(error)
        } catch {
            self.errorMessage = "Fehler beim Laden der Kategorien: \(error.localizedDescription)"
        }
    }
    
    // Lädt die Favoriten-Zitate aus Firestore
    func loadFavoriteQuotes() async throws { // Wirf einen Fehler, falls etwas schiefgeht
        do {
            if let fetchedQuotes = try await firebaseManager.fetchFavoriteQuotes() {
                self.quotes = fetchedQuotes // Setzt die abgerufenen Zitate
            }
        } catch {
            self.errorMessage = "Fehler beim Abrufen der Favoriten: \(error.localizedDescription)"
            throw error // Werfe den Fehler weiter, damit er im catch-Block von FavoriteView gefangen wird
        }
    }
    
    // Funktion, um den Favoritenstatus eines Zitats zu aktualisieren
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) {
        // Überprüfen, ob die Zitat-ID vorhanden und nicht leer ist
        guard !quote.id.isEmpty else {
            errorMessage = "Zitat-ID ist ungültig."
            return
        }
        
        // Referenz zum Firestore-Dokument
        let quoteRef = database.collection("quotes").document(quote.id)
        
        // Update der Favoriten-Eigenschaft in der Datenbank
        quoteRef.updateData([
            "isFavorite": isFavorite
        ]) { error in
            if let error = error {
                // Fehlerbehandlung, falls das Update fehlschlägt
                self.errorMessage = "Fehler beim Aktualisieren des Favoritenstatus: \(error.localizedDescription)"
            } else {
                // Erfolgreiche Aktualisierung
                if let index = self.quotes.firstIndex(where: { $0.id == quote.id }) {
                    self.quotes[index].isFavorite = isFavorite
                }
            }
        }
    }
}
