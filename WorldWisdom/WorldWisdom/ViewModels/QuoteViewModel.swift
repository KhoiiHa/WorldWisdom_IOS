//
//  QuoteViewModel.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 27.01.25.
//

import Foundation

// ViewModel zur Verwaltung und Anzeige der Zitate
class QuoteViewModel: ObservableObject {
    @Published var quotes: [Quote] = [] // Alle Zitate, die abgerufen wurden
    @Published var errorMessage: String? // Fehlernachricht (z. B. bei Netzwerkfehlern)
    
    // Lädt mehrere Zitate (z. B. zufällige Zitate)
    func loadMultipleQuotes() {
        Task {
            do {
                // Abrufen von mehreren zufälligen Zitaten
                let fetchedQuotes = try await QuoteService.shared.fetchMultipleQuotes()
                self.quotes = fetchedQuotes // Zitate zuweisen
            } catch {
                self.errorMessage = "Fehler beim Laden der Zitate: \(error.localizedDescription)"
            }
        }
    }

    // Lädt ein zufälliges Zitat
    func loadRandomQuote() {
        Task {
            do {
                // Abrufen eines einzelnen zufälligen Zitats
                let fetchedQuote = try await QuoteService.shared.fetchRandomQuote()
                self.quotes = [fetchedQuote] // Nur das zufällige Zitat anzeigen
            } catch {
                self.errorMessage = "Fehler beim Laden des Zitats: \(error.localizedDescription)"
            }
        }
    }

    // Lädt Zitate nach Kategorie
    func loadQuotesByCategory(category: String) {
        Task {
            do {
                // Abrufen von Zitaten nach einer bestimmten Kategorie
                let fetchedQuotes = try await QuoteService.shared.fetchQuotesByCategory(category: category)
                self.quotes = fetchedQuotes // Zitate zuweisen
            } catch {
                self.errorMessage = "Fehler beim Laden der Zitate: \(error.localizedDescription)"
            }
        }
    }

    // Lädt Zitate durch eine Suchanfrage
    func searchQuotes(query: String) {
        Task {
            do {
                // Abrufen von Zitaten, die der Suchanfrage entsprechen
                let fetchedQuotes = try await QuoteService.shared.searchQuotes(query: query)
                self.quotes = fetchedQuotes // Zitate zuweisen
            } catch {
                self.errorMessage = "Fehler bei der Suche: \(error.localizedDescription)"
            }
        }
    }

    // Lädt Zitate von einem bestimmten Autor
    func loadQuotesByAuthor(author: String) {
        Task {
            do {
                let fetchedQuotes = try await QuoteService.shared.fetchAuthorQuotes(authorName: author)
                self.quotes = fetchedQuotes // Zitate zuweisen
            } catch {
                self.errorMessage = "Fehler beim Laden der Zitate von \(author): \(error.localizedDescription)"
            }
        }
    }

    // Lädt alle Kategorien
    func loadCategories() {
        Task {
            do {
                _ = try await QuoteService.shared.fetchCategories()
                // Hier kannst du die Kategorien dann speichern oder verwenden, um sie im UI anzuzeigen
            } catch {
                self.errorMessage = "Fehler beim Laden der Kategorien: \(error.localizedDescription)"
            }
        }
    }
}
