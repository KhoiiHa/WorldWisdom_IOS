//
//  Quote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import Foundation

// Modelklasse für Zitat
struct Quote: Identifiable, Codable, Equatable {
    var id: String
    var author: String
    var quote: String
    var category: String
    var tags: [String]
    var isFavorite: Bool
    var description: String
    var source: String // URL zur Quelle des Zitats(WIKI-Link)
}
