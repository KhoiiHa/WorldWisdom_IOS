//
//  Quote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import SwiftData
import Foundation

/// SwiftData-Entity für Zitate, inklusive Offline-Unterstützung und Konvertierung zu Firebase-Modell

// MARK: - QuoteEntity
@Model
class QuoteEntity {
    @Attribute(.unique) var id: String
    var author: String
    var quoteText: String = ""
    var category: String
    var tagsJSON: String = "[]"
    var authorImageURLsJSON: String = "[]"

    // MARK: - Dekodierte JSON-Eigenschaften (tags & authorImageURLs)
    var tags: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data(tagsJSON.utf8))) ?? []
        }
        set {
            tagsJSON = (try? JSONEncoder().encode(newValue))
                .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        }
    }

    var authorImageURLs: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data(authorImageURLsJSON.utf8))) ?? []
        }
        set {
            authorImageURLsJSON = (try? JSONEncoder().encode(newValue))
                .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        }
    }

    var isFavorite: Bool
    var quoteDescription: String
    var source: String
    var authorImageData: Data?  // Offline-Bild (lokal gespeichert)

    // MARK: - Initialisierung
    init(id: String, author: String, quoteText: String, category: String, tags: [String] = [], isFavorite: Bool, quoteDescription: String, source: String, authorImageURLs: [String] = [], authorImageData: Data?) {
        self.id = id
        self.author = author
        self.quoteText = quoteText
        self.category = category
        self.tagsJSON = (try? JSONEncoder().encode(tags))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        self.isFavorite = isFavorite
        self.quoteDescription = quoteDescription
        self.source = source
        self.authorImageURLsJSON = (try? JSONEncoder().encode(authorImageURLs))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        self.authorImageData = authorImageData
    }

    // MARK: - Konvertierung zu Firebase-Modell
    // Konvertierung von SwiftData QuoteEntity zu Firebase Quote
    func toFirebaseModel() -> Quote {
        return Quote(
            id: self.id,
            author: self.author,
            quote: self.quoteText,
            category: self.category,
            tags: self.tags,
            isFavorite: self.isFavorite,
            description: self.quoteDescription,
            source: self.source,
            authorImageURLs: self.authorImageURLs
        )
    }
}

extension QuoteEntity {
    // MARK: - Konvertierung von Firebase-Modell zu QuoteEntity
    static func fromFirebaseModel(quote: Quote) -> QuoteEntity {
        return QuoteEntity(
            id: quote.id,
            author: quote.author,
            quoteText: quote.quote,
            category: quote.category,
            tags: quote.tags,
            isFavorite: quote.isFavorite,
            quoteDescription: quote.description,
            source: quote.source,
            authorImageURLs: quote.authorImageURLs ?? [],
            authorImageData: nil
        )
    }
}
