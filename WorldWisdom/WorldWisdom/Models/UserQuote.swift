//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 06.02.25.
//

import FirebaseFirestore

struct UserCreatedQuote: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String          // Der Benutzer, der das Zitat erstellt hat
    var quoteText: String       // Der Text des Zitats
    var author: String          // Der Autor des Zitats
    let createdAt: Timestamp    // Zeitpunkt der Erstellung
    var category: String?       // Optional: Kategorie des Zitats (z. B. Motivation, Erfolg)
}
