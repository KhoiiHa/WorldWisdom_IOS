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

/// Verwaltet das Speichern, Laden und Entfernen von Favoriten über Firebase & SwiftData

// MARK: - FavoriteManager
@MainActor
class FavoriteManager: ObservableObject {
    static let shared = FavoriteManager()
    private init() {}
    private let firebaseManager = FirebaseManager.shared
    private let syncManager = SwiftDataSyncManager()
    private let logger = Logger(subsystem: "com.deineApp.Zitate", category: "FavoriteManager")

    @Published private(set) var favoriteQuotes: [Quote] = []
    @Published var errorMessage: String?

    // MARK: - Favoriten laden

    /// Lädt Favoriten aus Firebase und SwiftData und führt sie zusammen.
    func loadFavoriteQuotes() async {
        do {
            // Firebase-Daten abrufen
            let firebaseQuotes = try await firebaseManager.fetchFavoriteQuotes()

            // Zitate aus Firebase sind bereits im Quote-Format

            // Lokale Daten von SwiftData abrufen
            let localQuotes = try await syncManager.fetchFavoriteQuotes()

            // Favoriten zusammenführen: Firebase-Daten haben Vorrang
            favoriteQuotes = mergeFavorites(firebaseQuotes, with: localQuotes)

            print("✅ Geladene Favoriten (gesamt): \(favoriteQuotes.count)")

            // Fehler-Reset, falls erfolgreich
            errorMessage = nil
        } catch let error as URLError {
            logger.error("Netzwerkfehler beim Laden der Favoriten: \(error.localizedDescription)")
            errorMessage = FavoriteError.networkError.errorMessage
        } catch let error as FirebaseError {
            logger.error("Fehler bei Firebase-Abfrage: \(error.localizedDescription)")
            errorMessage = FavoriteError.firebaseError.errorMessage
        } catch {
            logger.error("Fehler beim Laden der Favoriten: \(error.localizedDescription)")
            errorMessage = FavoriteError.unknownError.errorMessage
        }
    }

    // MARK: - Favorit hinzufügen

    /// Fügt ein Zitat als Favorit hinzu, sowohl in Firebase als auch in SwiftData.
    /// - Parameter quote: Das hinzuzufügende Zitat.
    func addFavoriteQuote(_ quote: Quote) async throws {
        guard !favoriteQuotes.contains(where: { $0.id == quote.id }) else {
            logger.warning("Zitat ist bereits in den Favoriten.")
            errorMessage = FavoriteError.favoriteAlreadyExists.errorMessage
            return
        }

        do {
            // Favoriten zuerst zu Firebase hinzufügen
            try await firebaseManager.saveFavoriteQuote(quote: quote)
            
            // Favoriten dann zu SwiftData hinzufügen
            try await syncManager.updateFavoriteStatus(for: quote, to: true)
            
            // Favoritenliste im ViewModel aktualisieren
            favoriteQuotes.append(quote)
        } catch let error as URLError {
            logger.error("Netzwerkfehler beim Hinzufügen des Zitats: \(error.localizedDescription)")
            errorMessage = FavoriteError.networkError.errorMessage
        } catch let error as FirebaseError {
            logger.error("Fehler beim Speichern auf Firebase: \(error.localizedDescription)")
            errorMessage = FavoriteError.firebaseError.errorMessage
        } catch {
            logger.error("Fehler beim Hinzufügen des Zitats: \(error.localizedDescription)")
            errorMessage = FavoriteError.unableToUpdateFavorite.errorMessage
            throw error
        }
    }

    // MARK: - Favorit entfernen

    /// Entfernt ein Zitat aus den Favoriten in Firebase und SwiftData.
    /// - Parameter quote: Das zu entfernende Zitat.
    func removeFavoriteQuote(_ quote: Quote) async throws {
        guard favoriteQuotes.contains(where: { $0.id == quote.id }) else {
            logger.warning("Zitat nicht in Favoriten gefunden.")
            throw FirebaseError.favoriteNotFound // Fehler werfen
        }

        do {
            // Zitat aus Firebase entfernen
            try await firebaseManager.deleteFavoriteQuote(quote)
            
            // Zitat aus SwiftData entfernen
            try await syncManager.removeFavoriteQuote(quote)
            
            // Favoritenliste im ViewModel aktualisieren
            favoriteQuotes.removeAll { $0.id == quote.id }

            // Favoriten erneut laden, um die neuesten Daten anzuzeigen
            await loadFavoriteQuotes()
        } catch let error as URLError {
            logger.error("Netzwerkfehler beim Entfernen des Zitats: \(error.localizedDescription)")
            throw FirebaseError.fetchFailed
        } catch let error as FirebaseError {
            logger.error("Fehler beim Entfernen des Zitats von Firebase: \(error.localizedDescription)")
            throw error
        } catch {
            logger.error("Fehler beim Entfernen des Zitats: \(error.localizedDescription)")
            throw FirebaseError.unknownError("Unbekannter Fehler beim Entfernen des Zitats.")
        }
    }
    
    // MARK: - Favoritenstatus aktualisieren

    /// Aktualisiert den Favoritenstatus eines Zitats.
    /// - Parameters:
    ///   - quote: Das zu aktualisierende Zitat.
    ///   - isFavorite: Neuer Favoritenstatus.
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        do {
            if isFavorite {
                try await addFavoriteQuote(quote)
            } else {
                try await removeFavoriteQuote(quote)
            }
        } catch let error as FavoriteError {
            logger.error("Fehler: \(error.errorMessage)")
        } catch {
            logger.error("Unbekannter Fehler: \(error.localizedDescription)")
        }
    }

    // MARK: - Hilfsfunktionen

    /// Führt Favoriten aus Firebase und SwiftData zusammen, wobei Firebase-Daten Vorrang haben.
    /// - Parameters:
    ///   - firebaseQuotes: Favoriten aus Firebase.
    ///   - localQuotes: Favoriten aus SwiftData.
    /// - Returns: Zusammengeführte Liste von Favoriten.
    private func mergeFavorites(_ firebaseQuotes: [Quote], with localQuotes: [Quote]) -> [Quote] {
        var merged = firebaseQuotes

        for localQuote in localQuotes {
            if !merged.contains(where: { $0.id == localQuote.id }) {
                merged.append(localQuote)
            }
        }

        return merged
    }
    
    // MARK: - Filter nach Autor

    /// Gibt alle Favoriten eines bestimmten Autors zurück.
    /// - Parameter author: Der Name des Autors.
    /// - Returns: Liste der Favoriten des Autors.
    func getFavoriteQuotesByAuthor(author: String) -> [Quote] {
        return favoriteQuotes.filter { $0.author == author }
    }
    
    // MARK: - Alle Favoriten entfernen

    /// Entfernt alle Favoriten aus Firebase und SwiftData und leert die lokale Liste.
    @MainActor
    func removeAllFavorites() async throws {
        try await firebaseManager.deleteAllFavoriteQuotes()
        try await syncManager.removeAllFavoriteQuotes()
        favoriteQuotes.removeAll()
    }
}
