//
//  Quote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import Foundation

// Modelklasse für Zitat
struct Quote: Codable,Identifiable {
    var id: String { quoteText } // Eindeutige ID basierend auf quoteText
    
    let quoteText: String  // "q" - Der Text des Zitats
    let author: String     // "a" - Der Autor des Zitats
    let html: String       // "h" - Das HTML-Format des Zitats (optional)
    let category: String?  // "c" - Die Kategorie des Zitats (optional)
    
    enum CodingKeys: String, CodingKey {
        case quoteText = "q"
        case author = "a"
        case html = "h"
        case category = "c"
    }
}
