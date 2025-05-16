//
//  Quote.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import Foundation

/// Datenmodell für Zitate – enthält alle relevanten Informationen für Anzeige, Filterung und Favoritenlogik.

// MARK: - Quote
struct Quote: Identifiable, Codable, Equatable, Hashable {
    var id: String                          // Eindeutige ID des Zitats
    var author: String                      // Name des Autors
    var quote: String                       // Der eigentliche Zitattext
    var category: String                    // Kategorie des Zitats (z. B. Motivation, Erfolg)
    var tags: [String]                      // Stichwörter für Filterung
    var isFavorite: Bool = false            // Ob das Zitat vom Nutzer favorisiert wurde
    var description: String                 // Kontext oder Hintergrund zum Zitat
    var source: String                      // URL zur Quelle des Zitats (z. B. Wikipedia-Link)
    var authorImageURLs: [String]?          // Liste mit URLs zu Autorenbildern (optional)
    var localImagePath: String?             // Lokaler Pfad für heruntergeladene Bilder (optional)
    var authorImageData: Data? = nil        // Zwischengespeicherte Bilddaten für Offline-Anzeige
}
