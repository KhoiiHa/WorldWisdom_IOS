//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import SwiftData
import Foundation

@Model
class FavoriteQuoteEntity {
    @Attribute(.unique) var id: String  
    var quoteId: String
    var userId: String
    var createdAt: Date
    var quoteText: String
    
    // Initialisierer
    init(id: String = UUID().uuidString, quoteId: String, userId: String, createdAt: Date, quoteText: String) {
        self.id = id
        self.quoteId = quoteId
        self.userId = userId
        self.createdAt = createdAt
        self.quoteText = quoteText
    }
    
    // Konvertierung von Firebase FavoriteQuote zu SwiftData FavoriteQuoteEntity
    static func fromFirebaseModel(favoriteQuote: FavoriteQuote) -> FavoriteQuoteEntity {
        // Überprüfen, ob die ID in Firebase vorhanden ist, ansonsten eine neue generieren
        let id = favoriteQuote.id ?? UUID().uuidString
        
        return FavoriteQuoteEntity(
            id: id,
            quoteId: favoriteQuote.quoteId,
            userId: favoriteQuote.userId,
            createdAt: favoriteQuote.createdAt.dateValue(),  // Sicherstellen, dass das Datum korrekt konvertiert wird
            quoteText: favoriteQuote.quoteText
        )
    }
}
