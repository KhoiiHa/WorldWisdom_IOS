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
    @Published var errorMessage: String? 

    // Favoriten aus Firestore laden
    func loadFavoriteQuotes() async {
        do {
            let quotes = try await firebaseManager.fetchFavoriteQuotes()
            favoriteQuotes = quotes
        } catch FavoriteError.userNotAuthenticated {
            logger.error("Benutzer nicht authentifiziert. Fehler beim Laden der Favoriten.")
            errorMessage = FavoriteError.userNotAuthenticated.errorMessage
        } catch {
            logger.error("Fehler beim Laden der Favoriten: \(error.localizedDescription)")
            errorMessage = FavoriteError.unknownError.errorMessage
        }
    }

    // Zitat zu Favoriten hinzufügen
    func addFavoriteQuote(_ quote: Quote) async throws {
        guard !favoriteQuotes.contains(where: { $0.id == quote.id }) else {
            logger.warning("Zitat ist bereits in den Favoriten.")
            errorMessage = FavoriteError.favoriteAlreadyExists.errorMessage
            return
        }

        do {
            try await firebaseManager.saveFavoriteQuote(quote: quote)
            favoriteQuotes.append(quote)
        } catch {
            logger.error("Fehler beim Hinzufügen des Zitats: \(error.localizedDescription)")
            errorMessage = FavoriteError.unableToUpdateFavorite.errorMessage
            throw error  
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
            errorMessage = FavoriteError.unableToUpdateFavorite.errorMessage
        }
    }

    // Favoritenstatus aktualisieren
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        do {
            if isFavorite {
                try await addFavoriteQuote(quote) // Fehlerbehandlung hinzugefügt
            } else {
                await removeFavoriteQuote(quote) // Fehlerbehandlung hinzugefügt
            }
        } catch let error as FavoriteError {
            // Verwende die Fehlerbeschreibung des Enums, um eine benutzerfreundliche Nachricht anzuzeigen
            print("Fehler: \(error.errorMessage)")
        } catch {
            // Allgemeine Fehlerbehandlung, falls es ein anderer Fehler ist
            print("Unbekannter Fehler: \(error.localizedDescription)")
        }
    }
}
