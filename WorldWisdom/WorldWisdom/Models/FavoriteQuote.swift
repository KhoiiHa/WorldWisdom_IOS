//
//  FavoriteQuote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import FirebaseFirestore

struct FavoriteQuote: Codable, Identifiable {
    @DocumentID var id: String?
    let text: String
    let author: String
    let category: String
    let userId: String
}
