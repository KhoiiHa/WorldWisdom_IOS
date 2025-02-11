//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 06.02.25.
//

import FirebaseFirestore

struct UserCreatedQuote: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    var quoteText: String
    var author: String
    let createdAt: Timestamp
    var category: String?
}
