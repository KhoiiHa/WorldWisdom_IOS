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
    
    // Initialisierer
    init(id: String = UUID().uuidString, quoteId: String, userId: String, quoteText: String) {
        self.id = id
        self.quoteId = quoteId
        self.userId = userId
        self.quoteText = quoteText
    }
    
    // Konvertierung von Firebase FavoriteQuote zu SwiftData FavoriteQuoteEntity
    static func fromFirebaseModel(favoriteQuote: FavoriteQuote) -> FavoriteQuoteEntity {
        let id = favoriteQuote.id ?? UUID().uuidString

        return FavoriteQuoteEntity(
            id: id,
            quoteId: favoriteQuote.quoteId,
            userId: favoriteQuote.userId,
            quoteText: favoriteQuote.quoteText
        )
    }
}
