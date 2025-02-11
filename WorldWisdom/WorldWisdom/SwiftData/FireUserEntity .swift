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
    var email: String?
    var name: String?
    var uid: String
    var favoriteQuoteIds: [String]
    
    init(id: String, email: String?, name: String?, uid: String, favoriteQuoteIds: [String]) {
        self.id = id
        self.email = email
        self.name = name
        self.uid = uid
        self.favoriteQuoteIds = favoriteQuoteIds
    }
    
    // Konvertierung von Firebase FireUser zu SwiftData FireUserEntity
    static func fromFirebaseModel(fireUser: FireUser) -> FireUserEntity {
        return FireUserEntity(
            id: fireUser.id,
            email: fireUser.email,
            name: fireUser.name,
            uid: fireUser.uid,
            favoriteQuoteIds: fireUser.favoriteQuoteIds
        )
    }
}
