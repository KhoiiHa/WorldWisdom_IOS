//
//  FavoriteManager.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 06.02.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import OSLog

@MainActor
class FavoriteManager: ObservableObject {
    private let firebaseManager = FirebaseManager.shared
    private let logger = Logger(subsystem: "com.deineApp.Zitate", category: "FavoriteManager")

    @Published private(set) var favoriteQuotes: [Quote] = []

    // Favoriten aus Firestore laden
    func loadFavoriteQuotes() async {
        do {
            let quotes = try await firebaseManager.fetchFavoriteQuotes()
            favoriteQuotes = quotes
        } catch FavoriteError.userNotAuthenticated {
            logger.error("Benutzer nicht authentifiziert. Fehler beim Laden der Favoriten.")
        } catch {
            logger.error("Fehler beim Laden der Favoriten: \(error.localizedDescription)")
        }
    }

    // Zitat zu Favoriten hinzufügen
    func addFavoriteQuote(_ quote: Quote) async {
        guard !favoriteQuotes.contains(where: { $0.id == quote.id }) else {
            logger.warning("Zitat ist bereits in den Favoriten.")
            return
        }
        
        do {
            try await firebaseManager.saveFavoriteQuote(quote: quote)
            favoriteQuotes.append(quote)
        } catch {
            logger.error("Fehler beim Hinzufügen des Zitats: \(error.localizedDescription)")
        }
    }

    // Favoriten-Zitat entfernen
    func removeFavoriteQuote(_ quote: Quote) async {
        guard favoriteQuotes.contains(where: { $0.id == quote.id }) else {
            logger.warning("Zitat nicht in Favoriten gefunden.")
            return
        }

        do {
            try await firebaseManager.deleteFavoriteQuote(quote)
            favoriteQuotes.removeAll { $0.id == quote.id }
        } catch {
            logger.error("Fehler beim Entfernen des Zitats: \(error.localizedDescription)")
        }
    }

    // Favoritenstatus aktualisieren
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        if isFavorite {
            await addFavoriteQuote(quote)
        } else {
            await removeFavoriteQuote(quote)
        }
    }
}
