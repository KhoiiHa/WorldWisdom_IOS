//
//  QuoteService.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import Foundation

class QuoteService {

    static let shared = QuoteService()

    // Basis-URL für Mockoon
    private let baseURL = "http://localhost:3001" // Mockoon läuft lokal auf Port 3001

    // Abrufen von Daten und Decodieren von JSON
    private func fetchData<T: Decodable>(from url: URL?) async throws -> T {
        guard let url = url else {
            throw QuoteError.networkError("Ungültige URL") // Fehlerbehandlung mit QuoteError
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            // Überprüfen, ob der Statuscode erfolgreich ist
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw QuoteError.networkError("Ungültige Serverantwort (Status: \((response as? HTTPURLResponse)?.statusCode ?? -1))")
            }

            return try JSONDecoder().decode(T.self, from: data)

        } catch let decodingError as DecodingError {
            throw QuoteError.parsingError("Fehler beim Decodieren der Daten: \(decodingError.localizedDescription)")
        } catch {
            throw QuoteError.handleError(error) // Generelle Fehlerbehandlung
        }
    }

    // Abrufen von mehreren zufälligen Zitaten (5 Zitate)
    func fetchMultipleQuotes() async throws -> [Quote] {
        return try await fetchData(from: URL(string: "\(baseURL)/api/random/5"))
    }

    // Abrufen eines zufälligen Zitats
    func fetchRandomQuote() async throws -> Quote {
        let quotes: [Quote] = try await fetchData(from: URL(string: "\(baseURL)/api/random/1"))
        guard let firstQuote = quotes.first else {
            throw QuoteError.noQuotesFound // Fehler werfen, wenn keine Zitate gefunden wurden
        }
        return firstQuote
    }
    
    // Zitate nach einem bestimmten Suchbegriff suchen
    func searchQuotes(query: String) async throws -> [Quote] {
        return try await fetchData(from: URL(string: "\(baseURL)/api/quotes/search?q=\(query)"))
    }

    // Zitate eines bestimmten Autors abrufen
    func fetchAuthorQuotes(authorName: String) async throws -> [Quote] {
        return try await fetchData(from: URL(string: "\(baseURL)/api/author/\(authorName)"))
    }

    // Abrufen aller Kategorien
    func fetchCategories() async throws -> [String] {
        return try await fetchData(from: URL(string: "\(baseURL)/api/categories"))
    }

    // Abrufen von Zitaten nach einer bestimmten Kategorie
    func fetchQuotesByCategory(category: String) async throws -> [Quote] {
        return try await fetchData(from: URL(string: "\(baseURL)/api/quotes/category/\(category)"))
    }

    // Details zu einem bestimmten Zitat abrufen
    func fetchQuoteDetails(id: String) async throws -> Quote {
        return try await fetchData(from: URL(string: "\(baseURL)/api/quote/\(id)"))
    }

    // Abrufen der Lieblingszitate eines Benutzers
    func fetchFavorites() async throws -> [Quote] {
        return try await fetchData(from: URL(string: "\(baseURL)/api/favorites"))
    }

    // Suchen von Zitaten anhand eines bestimmten Tags
    func searchQuotesByTags(tag: String) async throws -> [Quote] {
        return try await fetchData(from: URL(string: "\(baseURL)/api/quotes/tags/\(tag)"))
    }

    // Suchen von Zitaten anhand eines Tags und Autors
    func searchQuotesByTagAndAuthor(tag: String, author: String) async throws -> [Quote] {
        return try await fetchData(from: URL(string: "\(baseURL)/api/quotes/tags/\(tag)/author/\(author)"))
    }
}
