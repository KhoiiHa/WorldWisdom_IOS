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
            let quotes = try await firebaseManager.fetchFavoriteQuotes()
            self.favoriteQuotes = quotes
        } catch FavoriteError.userNotAuthenticated {
            // Handle spezifischen Fehler, wenn der Benutzer nicht authentifiziert ist
            print("Benutzer nicht authentifiziert. Fehler beim Laden der Favoriten.")
            throw FavoriteError.userNotAuthenticated
        } catch {
            // Handle andere Fehler und weiterwerfen
            print("Fehler beim Laden der Favoriten: \(error.localizedDescription)")
            throw error
        }
    }

    // Zitat zu Favoriten hinzufügen
    func addFavoriteQuote(_ quote: Quote) async throws {
        do {
            // Versuche das Zitat hinzuzufügen
            try await firebaseManager.saveFavoriteQuote(quote: quote)
            // Direktes Hinzufügen des Zitats zu den Favoriten ohne erneutes Laden der Liste
            self.favoriteQuotes.append(quote)
        } catch FavoriteError.favoriteAlreadyExists {
            print("Das Zitat ist bereits in den Favoriten.")
            throw FavoriteError.favoriteAlreadyExists
        } catch {
            print("Fehler beim Hinzufügen des Zitats zu den Favoriten: \(error.localizedDescription)")
            throw error
        }
    }

    // Favoriten-Zitat entfernen
    func removeFavoriteQuote(_ quote: Quote) async throws {
        do {
            // Versuche das Zitat zu entfernen
            try await firebaseManager.deleteFavoriteQuote(quote)
            // Direktes Entfernen des Zitats aus den Favoriten
            self.favoriteQuotes.removeAll { $0.id == quote.id }
        } catch {
            print("Fehler beim Entfernen des Zitats aus den Favoriten: \(error.localizedDescription)")
            throw error
        }
    }

    // Favoritenstatus aktualisieren
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async throws {
        if isFavorite {
            // Favorit hinzufügen
            try await addFavoriteQuote(quote)
        } else {
            // Favorit entfernen
            try await removeFavoriteQuote(quote)
        }
    }
}
