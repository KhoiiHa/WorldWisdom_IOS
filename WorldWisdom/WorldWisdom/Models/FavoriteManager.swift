//
//  FavoriteManager.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 06.02.25.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class FavoriteManager: ObservableObject {
    private let firebaseManager = FirebaseManager.shared
    
    @Published var favoriteQuotes: [Quote] = []
    
    // Favoriten aus Firestore laden
    func loadFavoriteQuotes() async throws {
        do {
            // Aufruf der fetchFavoriteQuotes Methode
            let quotes = try await firebaseManager.fetchFavoriteQuotes()
            self.favoriteQuotes = quotes
        } catch FavoriteError.userNotAuthenticated {
            // Handle spezifischen Fehler, wenn der Benutzer nicht authentifiziert ist
            throw FavoriteError.userNotAuthenticated
        } catch {
            // Handle andere Fehler und weiterwerfen
            throw error
        }
    }

    // Zitat zu Favoriten hinzufügen
    func addFavoriteQuote(_ quote: Quote) async throws {
        do {
            try await firebaseManager.saveFavoriteQuote(quote: quote)
            // Direktes Laden der Favoriten nach dem Hinzufügen
            try await loadFavoriteQuotes()
        } catch FavoriteError.favoriteAlreadyExists {
            throw FavoriteError.favoriteAlreadyExists
        } catch {
            throw error
        }
    }

    // Favoriten-Zitat entfernen
    func removeFavoriteQuote(_ quote: Quote) async throws {
        do {
            try await firebaseManager.deleteFavoriteQuote(quote)
            // Direktes Laden der Favoriten nach dem Entfernen
            try await loadFavoriteQuotes()
        } catch {
            throw error
        }
    }

    // Favoritenstatus aktualisieren
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async throws {
        if isFavorite {
            try await addFavoriteQuote(quote)
        } else {
            try await removeFavoriteQuote(quote)
        }
    }
}
