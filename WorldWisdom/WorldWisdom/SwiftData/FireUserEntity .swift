//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import SwiftData
import Foundation

/// SwiftData-Entity für Benutzerdaten, die aus Firebase geladen und lokal gespeichert werden.
/// Beinhaltet Konvertierungslogik von FireUser (Firebase-Modell) und Zugriff auf Favoriten-IDs.

// MARK: - FireUserEntity
@Model
class FireUserEntity {
    @Attribute(.unique) var id: String
    var email: String
    var name: String
    var uid: String
    @Attribute var favoriteQuoteIds: String 
    
    init(id: String, email: String, name: String, uid: String, favoriteQuoteIds: String) {
        self.id = id
        self.email = email
        self.name = name
        self.uid = uid
        self.favoriteQuoteIds = favoriteQuoteIds
    }
    
    // MARK: - Konvertierung von Firebase-Modell zu SwiftData-Entity
    // Konvertierung von Firebase FireUser zu SwiftData FireUserEntity
    static func fromFirebaseModel(fireUser: FireUser) -> FireUserEntity {
        // Stelle sicher, dass favoriteQuoteIds ein Array von Strings ist und konvertiere es korrekt
        let favoriteQuoteIdsString = fireUser.favoriteQuoteIds.joined(separator: ", ")
        
        return FireUserEntity(
            id: fireUser.id,
            email: fireUser.email ?? "",
            name: fireUser.name ?? "",
            uid: fireUser.uid,
            favoriteQuoteIds: favoriteQuoteIdsString
        )
    }
    
    // MARK: - Zugriff auf gespeicherte Quote-IDs als Array
    // Methode, um die gespeicherten Quote-IDs wieder als Array zurückzugeben
    func getFavoriteQuoteIdsArray() -> [String] {
        return favoriteQuoteIds.split(separator: ",").map { String($0) }
    }
}
