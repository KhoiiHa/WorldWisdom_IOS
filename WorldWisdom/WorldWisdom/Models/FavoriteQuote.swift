//
//  FavoriteQuote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import FirebaseFirestore

struct FavoriteQuote: Codable, Identifiable {
    @DocumentID var id: String?
    let quoteId: String
    let userId: String
    var quoteText: String
    let author: String
    let category: String?
    let tags: [String]?
    let authorImageURLs: [String]?
    let description: String?
    let source: String?
}
