//
//  FavoriteQuote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import FirebaseFirestore


struct FavoriteQuote: Codable, Identifiable {
    @DocumentID var id: String?
    let text: String       // Der Zitattext
    let author: String     // Der Autor des Zitats
    let category: String   // Kategorie des Zitats
    let userId: String     // Der Benutzer, der es favorisiert hat
    let createdAt: Timestamp // Zeitpunkt, wann es favorisiert wurde
}
