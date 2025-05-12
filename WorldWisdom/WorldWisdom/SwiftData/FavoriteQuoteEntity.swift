//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import SwiftData
import Foundation
import FirebaseFirestore

@Model
class FavoriteQuoteEntity {
    @Attribute(.unique) var id: String
    var quoteId: String
    var userId: String
    var quoteText: String
    var author: String
    var category: String?
    var tagsJSON: String?
    var authorImageURLsJSON: String?
    var quoteDescription: String?
    var source: String?
    
    var tags: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data((tagsJSON ?? "").utf8))) ?? []
        }
        set {
            tagsJSON = (try? JSONEncoder().encode(newValue)).flatMap { String(data: $0, encoding: .utf8) }
        }
    }

    var authorImageURLs: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data((authorImageURLsJSON ?? "").utf8))) ?? []
        }
        set {
            authorImageURLsJSON = (try? JSONEncoder().encode(newValue)).flatMap { String(data: $0, encoding: .utf8) }
        }
    }
    
    // Initialisierer
    init(id: String = UUID().uuidString, quoteId: String, userId: String, quoteText: String, author: String, category: String? = nil, tagsJSON: String? = nil, authorImageURLsJSON: String? = nil, description: String? = nil, source: String? = nil) {
        self.id = id
        self.quoteId = quoteId
        self.userId = userId
        self.quoteText = quoteText
        self.author = author
        self.category = category
        self.tagsJSON = tagsJSON
        self.authorImageURLsJSON = authorImageURLsJSON
        self.quoteDescription = description
        self.source = source
    }
    
    // Konvertierung von Firebase FavoriteQuote zu SwiftData FavoriteQuoteEntity
    static func fromFirebaseModel(favoriteQuote: FavoriteQuote) -> FavoriteQuoteEntity {
        let id = favoriteQuote.id ?? UUID().uuidString

        return FavoriteQuoteEntity(
            id: id,
            quoteId: favoriteQuote.quoteId,
            userId: favoriteQuote.userId,
            quoteText: favoriteQuote.quoteText,
            author: favoriteQuote.author,
            category: favoriteQuote.category,
            tagsJSON: (try? JSONEncoder().encode(favoriteQuote.tags)).flatMap { String(data: $0, encoding: .utf8) },
            authorImageURLsJSON: (try? JSONEncoder().encode(favoriteQuote.authorImageURLs)).flatMap { String(data: $0, encoding: .utf8) },
            description: favoriteQuote.description,
            source: favoriteQuote.source
        )
    }
}
