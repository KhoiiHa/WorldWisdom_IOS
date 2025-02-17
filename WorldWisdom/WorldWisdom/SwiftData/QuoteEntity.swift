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
    
    // Verwenden des @Attribute-Attributs für tags als Array von Strings
    @Attribute var tags: [String]?
    
    var isFavorite: Bool
    var quoteDescription: String
    var source: String
    var authorImageURL: String?  // URL des Remote-Bildes
    var authorImageData: Data?  // Offline-Bild (lokal gespeichert)

    // Initialisierer mit optionalem tags-Array
    init(id: String, author: String, quote: String, category: String, tags: [String]?, isFavorite: Bool, quoteDescription: String, source: String, authorImageURL: String?, authorImageData: Data?) {
        self.id = id
        self.author = author
        self.quote = quote
        self.category = category
        self.tags = tags
        self.isFavorite = isFavorite
        self.quoteDescription = quoteDescription
        self.source = source
        self.authorImageURL = authorImageURL
        self.authorImageData = authorImageData
    }

    // Konvertierung von Firebase Quote zu SwiftData QuoteEntity
    static func fromFirebaseModel(quote: Quote) -> QuoteEntity {
        return QuoteEntity(
            id: quote.id,
            author: quote.author,
            quote: quote.quote,
            category: quote.category,
            tags: quote.tags, // Direktes Zuweisen des Array
            isFavorite: quote.isFavorite,
            quoteDescription: quote.description,
            source: quote.source,
            authorImageURL: quote.authorImageURL,
            authorImageData: nil  // Bild wird später geladen (wird später gesetzt)
        )
    }

    // Konvertierung von SwiftData QuoteEntity zu Firebase Quote
    func toFirebaseModel() -> Quote {
        return Quote(
            id: self.id,
            author: self.author,
            quote: self.quote,
            category: self.category,
            tags: self.tags ?? [], // Wenn tags nil ist, ein leeres Array zurückgeben
            isFavorite: self.isFavorite,
            description: self.quoteDescription,
            source: self.source,
            authorImageURL: self.authorImageURL ?? "" // Das authorImageURL hier berücksichtigen
        )
    }
}
