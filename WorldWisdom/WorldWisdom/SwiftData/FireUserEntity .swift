//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import SwiftData
import Foundation

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
    
    // Methode, um die gespeicherten Quote-IDs wieder als Array zurückzugeben
    func getFavoriteQuoteIdsArray() -> [String] {
        return favoriteQuoteIds.split(separator: ",").map { String($0) }
    }
}
