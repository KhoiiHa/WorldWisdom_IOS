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
            // Firebase-Daten abrufen
            let firebaseQuotes = try await firebaseManager.fetchFavoriteQuotes()
            
            // Lokale Daten von SwiftData abrufen
            let localQuotes = try await syncManager.fetchFavoriteQuotes()

            // Favoriten zusammenführen: Firebase-Daten haben Vorrang
            let mergedQuotes = mergeFavorites(firebaseQuotes, with: localQuotes)
            favoriteQuotes = mergedQuotes
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

    // Zitat zu Favoriten hinzufügen (Firebase + SwiftData)
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

    // Favoriten-Zitat entfernen (Firebase + SwiftData)
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
    
    // Favoritenstatus aktualisieren
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

    // Funktion zum Abrufen des vollständigen Zitats
    func fetchCompleteQuote(for favoriteQuote: FavoriteQuote) async throws -> Quote? {
        let db = Firestore.firestore()

        // Abrufen des Zitats aus Firestore
        let snapshot = try await db.collection("quotes").document(favoriteQuote.quoteId).getDocument()

        // Prüfen, ob das Dokument existiert
        guard let data = snapshot.data() else {
            // Wenn keine Daten vorhanden sind, werfen wir einen Fehler
            throw QuoteError.noQuotesFound
        }

        do {
            // Direktes Decodieren der Daten in das Quote-Modell
            let decodedQuote = try Firestore.Decoder().decode(Quote.self, from: data)
            return decodedQuote
        } catch {
            // Wenn das Decodieren fehlschlägt, werfen wir einen Fehler
            throw QuoteError.parsingError("Fehler beim Decodieren des Zitats.")
        }
    }
}
