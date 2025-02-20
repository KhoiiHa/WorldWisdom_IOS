//
//  Quote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import SwiftData
import Foundation

@Model
class QuoteEntity {
    @Attribute(.unique) var id: String
    var author: String
    var quote: String
    var category: String
    var tags: [String]?
    var isFavorite: Bool
    var quoteDescription: String
    var source: String
    var authorImageURLs: [String]?
    var authorImageData: Data?  // Offline-Bild (lokal gespeichert)

    init(id: String, author: String, quote: String, category: String, tags: [String]?, isFavorite: Bool, quoteDescription: String, source: String, authorImageURLs: [String]?, authorImageData: Data?) {
        self.id = id
        self.author = author
        self.quote = quote
        self.category = category
        self.tags = tags
        self.isFavorite = isFavorite
        self.quoteDescription = quoteDescription
        self.source = source
        self.authorImageURLs = authorImageURLs
        self.authorImageData = authorImageData
    }

    // Konvertierung von Firebase Quote zu SwiftData QuoteEntity
    static func fromFirebaseModel(quote: Quote) -> QuoteEntity {
        return QuoteEntity(
            id: quote.id,
            author: quote.author,
            quote: quote.quote,
            category: quote.category,
            tags: quote.tags,
            isFavorite: quote.isFavorite,
            quoteDescription: quote.description,
            source: quote.source,
            authorImageURLs: quote.authorImageURLs, 
            authorImageData: nil
        )
    }

    // Konvertierung von SwiftData QuoteEntity zu Firebase Quote
    func toFirebaseModel() -> Quote {
        return Quote(
            id: self.id,
            author: self.author,
            quote: self.quote,
            category: self.category,
            tags: self.tags ?? [],
            isFavorite: self.isFavorite,
            description: self.quoteDescription,
            source: self.source,
            authorImageURLs: self.authorImageURLs ?? []
        )
    }
}
