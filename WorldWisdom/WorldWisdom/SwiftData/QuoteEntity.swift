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
    var tags: String  // Tags als String speichern (durch Komma getrennt)
    var isFavorite: Bool
    var quoteDescription: String
    var source: String
    
    init(id: String, author: String, quote: String, category: String, tags: String, isFavorite: Bool, quoteDescription: String, source: String) {
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
        // Tags als String speichern
        let tagsString = quote.tags.joined(separator: ", ")
        
        return QuoteEntity(
            id: quote.id,
            author: quote.author,
            quote: quote.quote,
            category: quote.category,
            tags: tagsString,
            isFavorite: quote.isFavorite,
            quoteDescription: quote.description,
            source: quote.source
        )
    }
    
    // Konvertierung von SwiftData QuoteEntity zu Firebase Quote
    func toFirebaseModel() -> Quote {
        // Tags wieder als Array zurückwandeln
        let tagsArray = self.tags.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        
        return Quote(
            id: self.id,
            author: self.author,
            quote: self.quote,
            category: self.category,
            tags: tagsArray,
            isFavorite: self.isFavorite,
            description: self.quoteDescription,
            source: self.source
        )
    }
}
