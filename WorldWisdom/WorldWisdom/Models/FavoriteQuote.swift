//
//  FavoriteQuote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import FirebaseFirestore

struct FavoriteQuote: Codable, Identifiable {
    @DocumentID var id: String?
    let quoteId: String     // Verweis auf das Zitat, das favorisiert wurde
    let userId: String     // Der Benutzer, der es favorisiert hat
    let createdAt: Timestamp // Zeitpunkt, wann es favorisiert wurde
    var quoteText: String
}
