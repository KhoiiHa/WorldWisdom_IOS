//
//  FavoriteManager.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 06.02.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftData
import OSLog

@MainActor
class FavoriteManager: ObservableObject {
    private let firebaseManager = FirebaseManager.shared
    private let syncManager = SwiftDataSyncManager()
    private let logger = Logger(subsystem: "com.deineApp.Zitate", category: "FavoriteManager")

    @Published private(set) var favoriteQuotes: [Quote] = []
    @Published var errorMessage: String?

    // Favoriten aus Firestore & SwiftData laden
    func loadFavoriteQuotes() async {
        do {
            let firebaseQuotes = try await firebaseManager.fetchFavoriteQuotes()
            let localQuotes = try await syncManager.fetchFavoriteQuotes() // Lokale Favoriten über syncManager laden

            let mergedQuotes = mergeFavorites(firebaseQuotes, with: localQuotes)
            favoriteQuotes = mergedQuotes
        } catch FavoriteError.userNotAuthenticated {
            logger.error("Benutzer nicht authentifiziert. Fehler beim Laden der Favoriten.")
            errorMessage = FavoriteError.userNotAuthenticated.errorMessage
        } catch {
            logger.error("Fehler beim Laden der Favoriten: \(error.localizedDescription)")
            errorMessage = "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)"
        }
    }

    // Zitat zu Favoriten hinzufügen (Firebase + SwiftData)
    func addFavoriteQuote(_ quote: Quote) async throws {
        guard !favoriteQuotes.contains(where: { $0.id == quote.id }) else {
            logger.warning("Zitat ist bereits in den Favoriten.")
            errorMessage = FavoriteError.favoriteAlreadyExists.errorMessage
            return
        }

        do {
            // Zuerst in Firebase speichern
            try await firebaseManager.saveFavoriteQuote(quote: quote)
            
            // Dann den Favoritenstatus in SwiftData aktualisieren
            try await syncManager.updateFavoriteStatus(for: quote, to: true)
            
            // Favoritenliste im ViewModel aktualisieren
            favoriteQuotes.append(quote)
        } catch {
            logger.error("Fehler beim Hinzufügen des Zitats: \(error.localizedDescription)")
            errorMessage = "Fehler beim Speichern des Zitats: \(error.localizedDescription)"
            throw error
        }
    }

    // Favoriten-Zitat entfernen (Firebase + SwiftData)
    func removeFavoriteQuote(_ quote: Quote) async {
        guard favoriteQuotes.contains(where: { $0.id == quote.id }) else {
            logger.warning("Zitat nicht in Favoriten gefunden.")
            return
        }

        do {
            try await firebaseManager.deleteFavoriteQuote(quote)
            try await syncManager.removeFavoriteQuote(quote) // Favoriten aus SwiftData entfernen über syncManager

            favoriteQuotes.removeAll { $0.id == quote.id }
            
            // Favoriten nach Entfernen erneut laden, um sicherzustellen, dass die neuesten Daten angezeigt werden
            await loadFavoriteQuotes()
        } catch {
            logger.error("Fehler beim Entfernen des Zitats: \(error.localizedDescription)")
            errorMessage = "Fehler beim Entfernen des Zitats: \(error.localizedDescription)"
        }
    }

    // Favoritenstatus aktualisieren
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        do {
            if isFavorite {
                try await addFavoriteQuote(quote)
            } else {
                await removeFavoriteQuote(quote)
            }
        } catch let error as FavoriteError {
            logger.error("Fehler: \(error.errorMessage)")
        } catch {
            logger.error("Unbekannter Fehler: \(error.localizedDescription)")
        }
    }

    // Hilfsfunktion: Firebase- und SwiftData-Favoriten zusammenführen
    private func mergeFavorites(_ firebaseQuotes: [Quote], with localQuotes: [Quote]) -> [Quote] {
        var merged = firebaseQuotes

        for localQuote in localQuotes {
            if !merged.contains(where: { $0.id == localQuote.id }) {
                merged.append(localQuote)
            }
        }

        return merged
    }
}
