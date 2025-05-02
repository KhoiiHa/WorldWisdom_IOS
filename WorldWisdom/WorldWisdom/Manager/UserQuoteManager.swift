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
    static let shared = UserQuoteManager()
    private init() {}
    private let firebaseManager = FirebaseManager.shared  

    @Published var userQuotes: [Quote] = []
    @Published var errorMessage: String?

    // Benutzerdefinierte Zitate abrufen
    func loadUserQuotes() async {
        do {
            let quotes = try await firebaseManager.fetchUserQuotes()
            self.userQuotes = quotes
        } catch {
            self.errorMessage = "Fehler beim Laden der Zitate: \(error.localizedDescription)"
            print("Fehler beim Laden der Zitate: \(error)")
        }
    }

    // Neues Zitat speichern
    func addUserQuote(quoteText: String, author: String, authorImageURL: String? = nil) async {
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
            try await firebaseManager.saveUserQuote(quoteText: quoteText, author: author, authorImageURL: authorImageURL!)
            await loadUserQuotes()
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Fehler beim Speichern des Zitats: \(error.localizedDescription)"
            print("Fehler beim Speichern des Zitats: \(error)")
        }
    }
}
