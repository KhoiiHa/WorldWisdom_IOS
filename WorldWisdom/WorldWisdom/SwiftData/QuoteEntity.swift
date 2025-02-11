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
    var tags: [String]
    var isFavorite: Bool
    var quoteDescription: String
    var source: String
    
    init(id: String, author: String, quote: String, category: String, tags: [String], isFavorite: Bool, quoteDescription: String, source: String) {
        self.id = id
        self.author = author
        self.quote = quote
        self.category = category
        self.tags = tags
        self.isFavorite = isFavorite
        self.quoteDescription = quoteDescription
        self.source = source
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
            source: quote.source
        )
    }
}
