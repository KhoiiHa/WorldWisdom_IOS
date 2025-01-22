//
//  QuoteService.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import Foundation

class QuoteService {

    static let shared = QuoteService()

    private let quotesURL = URL(string: "https://zenquotes.io/api/quotes")!
    private let randomQuoteURL = URL(string: "https://zenquotes.io/api/random")!

    // Abrufen von mehreren Zitaten
    func fetchMultipleQuotes() async throws -> [Quote] {
        let (data, _) = try await URLSession.shared.data(from: quotesURL)
        let quotes = try JSONDecoder().decode([Quote].self, from: data)
        return quotes
    }

    // Abrufen eines zufälligen Zitats
    func fetchRandomQuote() async throws -> Quote {
        let (data, _) = try await URLSession.shared.data(from: randomQuoteURL)
        let quote = try JSONDecoder().decode([Quote].self, from: data).first!
        return quote
    }
}
