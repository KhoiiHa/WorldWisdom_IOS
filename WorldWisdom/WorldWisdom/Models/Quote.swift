//
//  Quote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import Foundation

// Modelklasse für Zitat
struct Quote: Identifiable, Codable {
    var id: String
    var author: String
    var quote: String
    var category: String
    var tags: [String]
    var isFavorite: Bool
    var description: String
    var source: String // für die Wikipedia-URL
}
