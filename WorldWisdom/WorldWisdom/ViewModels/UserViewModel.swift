//
//  UserViewModel.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 16.01.25.
//

import SwiftUI
import FirebaseAuth
import Foundation
import FirebaseFirestore

@MainActor
class UserViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
    @Published var user: FireUser?
    @Published var favoriteQuotes: [FavoriteQuote] = []

    // MARK: - Anmeldestatus Funktionen

    // Funktion zum Speichern des Anmeldestatus
    private func saveLoginStatus(isLoggedIn: Bool) {
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
    }

    // Funktion zum Abrufen des Anmeldestatus
    func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }

    // MARK: - Validierungsfunktionen

    // Validierung der E-Mail
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    // Validierung des Passworts
    func isValidPassword(password: String) -> Bool {
        return password.count >= 6
    }

    // MARK: - Authentifizierungsfunktionen

    // Funktion für die Registrierung mit E-Mail und Passwort
    func registerUser(email: String, password: String) async {
        if !isValidEmail(email: email) {
            self.errorMessage = "Die E-Mail-Adresse ist ungültig."
            return
        }
        if !isValidPassword(password: password) {
            self.errorMessage = "Das Passwort muss mindestens 6 Zeichen lang sein."
            return
        }

        do {
            let authResult = try await FirebaseManager.shared.registerUser(email: email, password: password)
            self.isLoggedIn = true

            let newUser = FireUser(id: authResult.user.uid, email: email, uid: authResult.user.uid)
            self.user = newUser
            print("Benutzer erfolgreich registriert. UID: \(newUser.uid)")

            try await FirebaseManager.shared.createUserInFirestore(id: authResult.user.uid, email: email)
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Fehler bei der Registrierung: \(error.localizedDescription)"
            print(self.errorMessage ?? "Unbekannter Fehler")
        }
    }

    // Funktion für die Anmeldung mit E-Mail und Passwort
    func loginUser(email: String, password: String) async {
        if !isValidEmail(email: email) {
            self.errorMessage = "Die E-Mail-Adresse ist ungültig."
            return
        }
        if !isValidPassword(password: password) {
            self.errorMessage = "Das Passwort muss mindestens 6 Zeichen lang sein."
            return
        }

        do {
            let authResult = try await FirebaseManager.shared.loginUser(email: email, password: password)
            self.isLoggedIn = true

            let loggedInUser = FireUser(id: authResult.user.uid, email: email, uid: authResult.user.uid)
            self.user = loggedInUser
            print("Benutzer erfolgreich angemeldet. UID: \(loggedInUser.uid)")
        } catch {
            self.errorMessage = "Fehler bei der Anmeldung: \(error.localizedDescription)"
            print(self.errorMessage ?? "Unbekannter Fehler")
        }
    }

    // Funktion für anonyme Anmeldung
    func anonymousLogin() async {
        do {
            let authResult = try await FirebaseManager.shared.anonymousLogin()
            self.isLoggedIn = true

            let anonymousUser = FireUser(id: authResult.user.uid, email: nil, uid: authResult.user.uid)
            self.user = anonymousUser
            print("Anonyme Anmeldung erfolgreich. UID: \(anonymousUser.uid)")
        } catch {
            self.errorMessage = "Fehler bei der anonymen Anmeldung: \(error.localizedDescription)"
            print(self.errorMessage ?? "Unbekannter Fehler")
        }
    }

    // MARK: - Benutzerstatus Funktionen

    // Funktion, um beim Start zu prüfen, ob der Benutzer bereits angemeldet ist
    func checkCurrentUser() {
        if let currentUser = FirebaseManager.shared.currentUser {
            self.isLoggedIn = true
            let existingUser = FireUser(id: currentUser.uid, email: currentUser.email, uid: currentUser.uid)
            self.user = existingUser
            print("Aktueller Benutzer: \(currentUser.email ?? "Unbekannt")")
        } else {
            self.isLoggedIn = false
            self.user = nil
            print("Kein Benutzer angemeldet.")
        }
    }

    // Funktion zum Abmelden
    func signOut() async {
        do {
            try FirebaseManager.shared.signOut()
            self.isLoggedIn = false
            self.user = nil
            print("Benutzer abgemeldet: \(self.user?.email ?? "Unbekannt").")
        } catch {
            self.errorMessage = "Fehler beim Abmelden: \(error.localizedDescription)"
            print(self.errorMessage ?? "Unbekannter Fehler")
        }
    }

    // MARK: - Firestore Funktionen

    // Funktion zum Abrufen der Lieblingszitate
    func fetchFavoriteQuotes(for userId: String) async {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("favoriteQuotes")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()

            let quotes = snapshot.documents.compactMap { document in
                try? document.data(as: FavoriteQuote.self)
            }
            self.favoriteQuotes = quotes
        } catch {
            print("Fehler beim Abrufen der Zitate: \(error.localizedDescription)")
        }
    }
}
