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
    @Published var errorMessage: String? // 🔹 Fehlernachricht für die Benutzeroberfläche

    // Benutzerdefinierte Zitate abrufen
    func loadUserQuotes() async {
        do {
            let quotes = try await firebaseManager.fetchUserQuotes() // 🔹 Zugriff auf FirebaseManager
            self.userQuotes = quotes
        } catch {
            self.errorMessage = "Fehler beim Laden der Zitate: \(error.localizedDescription)"
            print("Fehler beim Laden der Zitate: \(error)")
        }
    }

    // Neues Zitat speichern
    func addUserQuote(quoteText: String, author: String) async {
        // Überprüfen, ob das Zitat und der Autor nicht leer sind
        guard !quoteText.isEmpty else {
            self.errorMessage = "Das Zitat darf nicht leer sein."
            return
        }
        guard !author.isEmpty else {
            self.errorMessage = "Der Autor darf nicht leer sein."
            return
        }

        do {
            try await firebaseManager.saveUserQuote(quoteText: quoteText, author: author)
            await loadUserQuotes() // 🔹 Liste sofort aktualisieren
            self.errorMessage = nil // Fehler zurücksetzen, wenn der Vorgang erfolgreich war
        } catch {
            self.errorMessage = "Fehler beim Speichern des Zitats: \(error.localizedDescription)"
            print("Fehler beim Speichern des Zitats: \(error)")
        }
    }
}
