//
//  User.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 21.01.25.
//

// User Model für die Benutzerdaten
struct FireUser: Codable {
    let id: String
    let email: String?
    let name: String?
    let uid: String
    var favoriteQuoteIds: [String] = [] // Liste von favorisierten Zitat-IDs
}
