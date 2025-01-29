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
    private func fetchData<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Überprüfen, ob der Statuscode erfolgreich ist
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return decodedData
    }

    // Abrufen von mehreren zufälligen Zitaten (5 Zitate)
    func fetchMultipleQuotes() async throws -> [Quote] {
        let url = URL(string: "\(baseURL)/api/random/5")!
        return try await fetchData(from: url)
    }

    // Abrufen eines zufälligen Zitats
    func fetchRandomQuote() async throws -> Quote {
        let url = URL(string: "\(baseURL)/api/random/1")!
        let quotes: [Quote] = try await fetchData(from: url)
        return quotes.first! // Holt das erste zufällige Zitat
    }
    
    // Zitate nach einem bestimmten Suchbegriff suchen
    func searchQuotes(query: String) async throws -> [Quote] {
        let url = URL(string: "\(baseURL)/api/quotes/search?q=\(query)")!
        return try await fetchData(from: url)
    }

    // Zitate eines bestimmten Autors abrufen
    func fetchAuthorQuotes(authorName: String) async throws -> [Quote] {
        let url = URL(string: "\(baseURL)/api/author/\(authorName)")!
        return try await fetchData(from: url)
    }

    // Abrufen aller Kategorien
    func fetchCategories() async throws -> [String] {
        let url = URL(string: "\(baseURL)/api/categories")!
        return try await fetchData(from: url)
    }

    // Abrufen von Zitaten nach einer bestimmten Kategorie
    func fetchQuotesByCategory(category: String) async throws -> [Quote] {
        let url = URL(string: "\(baseURL)/api/quotes/category/\(category)")!
        return try await fetchData(from: url)
    }

    // Details zu einem bestimmten Zitat abrufen
    func fetchQuoteDetails(id: String) async throws -> Quote {
        let url = URL(string: "\(baseURL)/api/quote/\(id)")!
        return try await fetchData(from: url)
    }

    // Abrufen der Lieblingszitate eines Benutzers
    func fetchFavorites() async throws -> [Quote] {
        let url = URL(string: "\(baseURL)/api/favorites")!
        return try await fetchData(from: url)
    }

    // Suchen von Zitaten anhand eines bestimmten Tags
    func searchQuotesByTags(tag: String) async throws -> [Quote] {
        let url = URL(string: "\(baseURL)/api/quotes/tags/\(tag)")!
        return try await fetchData(from: url)
    }

    // Suchen von Zitaten anhand eines Tags und Autors
    func searchQuotesByTagAndAuthor(tag: String, author: String) async throws -> [Quote] {
        let url = URL(string: "\(baseURL)/api/quotes/tags/\(tag)/author/\(author)")!
        return try await fetchData(from: url)
    }
}
