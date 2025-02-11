//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import SwiftData
import Foundation

@Model
class UserCreatedQuoteEntity {
    @Attribute(.unique) var id: String
    var userId: String
    var quoteText: String
    var author: String
    var createdAt: Date
    var category: String?
    
    init(id: String, userId: String, quoteText: String, author: String, createdAt: Date, category: String?) {
        self.id = id
        self.userId = userId
        self.quoteText = quoteText
        self.author = author
        self.createdAt = createdAt
        self.category = category
    }
    
    // Konvertierung von Firebase UserCreatedQuote zu SwiftData UserCreatedQuoteEntity
    static func fromFirebaseModel(userCreatedQuote: UserCreatedQuote) -> UserCreatedQuoteEntity {
        return UserCreatedQuoteEntity(
            id: userCreatedQuote.id ?? UUID().uuidString,
            userId: userCreatedQuote.userId,
            quoteText: userCreatedQuote.quoteText,
            author: userCreatedQuote.author,
            createdAt: userCreatedQuote.createdAt.dateValue(),
            category: userCreatedQuote.category
        )
    }
}
