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
    private let auth = Auth.auth()
    private let store = Firestore.firestore()
    
    @Published var favoriteQuotes: [Quote] = []
    @Published var errorMessage: String?
    
    // ✅ Favoriten aus Firestore laden
    func loadFavoriteQuotes() async throws {
        guard let currentUser = auth.currentUser else {
            throw FavoriteError.userNotAuthenticated // Fehler werfen, wenn der Benutzer nicht authentifiziert ist
        }
        
        let userRef = store.collection("users").document(currentUser.uid)
        let userDoc = try await userRef.getDocument()
        let favoriteQuoteIds = userDoc.data()?["favoriteQuoteIds"] as? [String] ?? []
        
        var quotes: [Quote] = []
        for quoteId in favoriteQuoteIds {
            let quoteDoc = try await store.collection("quotes").document(quoteId).getDocument()
            
            if let data = quoteDoc.data() {
                let decoder = Firestore.Decoder()
                if let quote = try? decoder.decode(Quote.self, from: data) {
                    quotes.append(quote)
                }
            }
        }
        
        // Favoriten updaten
        self.favoriteQuotes = quotes
    }

    // ✅ Zitat zu Favoriten hinzufügen
    func addFavoriteQuote(_ quote: Quote) async throws {
        guard let currentUser = auth.currentUser else {
            throw FavoriteError.userNotAuthenticated // Fehler werfen, wenn der Benutzer nicht authentifiziert ist
        }
        
        let userRef = store.collection("users").document(currentUser.uid)
        let userDoc = try await userRef.getDocument()
        var favoriteQuoteIds = userDoc.data()?["favoriteQuoteIds"] as? [String] ?? []
        
        if favoriteQuoteIds.contains(quote.id) {
            throw FavoriteError.favoriteAlreadyExists // Fehler werfen, wenn das Zitat schon in den Favoriten ist
        }
        
        favoriteQuoteIds.append(quote.id)
        
        // Update innerhalb des MainActors und synchron
        await MainActor.run {
            userRef.updateData(["favoriteQuoteIds": favoriteQuoteIds]) { error in
                if let error = error {
                    print("Fehler beim Aktualisieren der Favoriten: \(error.localizedDescription)")
                }
            }
        }
        
        try await loadFavoriteQuotes()
    }

    // ✅ Favoriten-Zitat entfernen
    func removeFavoriteQuote(_ quote: Quote) async throws {
        guard let currentUser = auth.currentUser else {
            throw FavoriteError.userNotAuthenticated // Fehler werfen, wenn der Benutzer nicht authentifiziert ist
        }
        
        let userRef = store.collection("users").document(currentUser.uid)
        let userDoc = try await userRef.getDocument()
        var favoriteQuoteIds = userDoc.data()?["favoriteQuoteIds"] as? [String] ?? []
        
        favoriteQuoteIds.removeAll { $0 == quote.id }
        
        // Update innerhalb des MainActors und synchron
        await MainActor.run {
            userRef.updateData(["favoriteQuoteIds": favoriteQuoteIds]) { error in
                if let error = error {
                    print("Fehler beim Entfernen des Favoriten: \(error.localizedDescription)")
                }
            }
        }
        
        try await loadFavoriteQuotes()
    }

    // ✅ Favoritenstatus aktualisieren
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async {
        do {
            if isFavorite {
                try await addFavoriteQuote(quote)
            } else {
                try await removeFavoriteQuote(quote)
            }
        } catch let error as FavoriteError {
            self.errorMessage = error.rawValue // Fehlernachricht von FavoriteError setzen
        } catch {
            self.errorMessage = "Unbekannter Fehler: \(error.localizedDescription)" // Allgemeine Fehlernachricht
        }
    }
}
