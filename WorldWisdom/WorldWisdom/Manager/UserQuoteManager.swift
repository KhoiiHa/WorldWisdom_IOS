//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 06.02.25.
//

import Foundation
import SwiftUI

@MainActor
class UserQuoteManager: ObservableObject {
    private let firebaseManager = FirebaseManager.shared  // 🔹 Richtig referenzieren

    @Published var userQuotes: [Quote] = []

    // Benutzerdefinierte Zitate abrufen
    func loadUserQuotes() async throws {
        do {
            let quotes = try await firebaseManager.fetchUserQuotes() // 🔹 Zugriff auf FirebaseManager
            self.userQuotes = quotes
        } catch {
            throw error
        }
    }

    // Neues Zitat speichern
    func addUserQuote(quoteText: String, author: String) async throws {
        do {
            try await firebaseManager.saveUserQuote(quoteText: quoteText, author: author)
            try await loadUserQuotes() // 🔹 Liste sofort aktualisieren
        } catch {
            throw error
        }
    }
}
