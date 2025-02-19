//
//  Quote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

struct Quote: Identifiable, Codable, Equatable {
    var id: String
    var author: String
    var quote: String
    var category: String
    var tags: [String]
    var isFavorite: Bool
    var description: String
    var source: String // URL zur Quelle des Zitats (z.B. Wikipedia-Link)
    var authorImageURLs: [String]? 
    var localImagePath: String? // Optionaler lokaler Pfad des heruntergeladenen Bildes (Offline)
}
