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

    // Funktion für die Registrierung mit E-Mail und Passwort
    func registerUser(email: String, password: String) async {
        do {
            // Registrierung über den FirebaseManager
            let authResult = try await FirebaseManager.shared.registerUser(email: email, password: password)
            self.isLoggedIn = true

            // Benutzer in Firestore speichern
            let newUser = FireUser(id: authResult.user.uid, email: email, uid: authResult.user.uid)
            self.user = newUser
            print("Benutzer erfolgreich registriert. UID: \(newUser.uid)")

            // Benutzer in Firestore speichern
            try await FirebaseManager.shared.createUserInFirestore(id: authResult.user.uid, email: email)
        } catch {
            self.errorMessage = "Fehler bei der Registrierung: \(error.localizedDescription)"
            print(self.errorMessage ?? "Unbekannter Fehler")
        }
    }

    // Funktion für die Anmeldung mit E-Mail und Passwort
    func loginUser(email: String, password: String) async {
        do {
            // Anmeldung über den FirebaseManager
            let authResult = try await FirebaseManager.shared.loginUser(email: email, password: password)
            self.isLoggedIn = true

            // Benutzerinformationen speichern
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
            // Anonyme Anmeldung über den FirebaseManager
            let authResult = try await FirebaseManager.shared.anonymousLogin()
            self.isLoggedIn = true

            // Benutzerinformationen speichern
            let anonymousUser = FireUser(id: authResult.user.uid, email: nil, uid: authResult.user.uid)
            self.user = anonymousUser
            print("Anonyme Anmeldung erfolgreich. UID: \(anonymousUser.uid)")
        } catch {
            self.errorMessage = "Fehler bei der anonymen Anmeldung: \(error.localizedDescription)"
            print(self.errorMessage ?? "Unbekannter Fehler")
        }
    }

    // Funktion, um beim Start zu prüfen, ob der Benutzer bereits angemeldet ist
    func checkCurrentUser() {
        if let currentUser = FirebaseManager.shared.currentUser { // Verwende currentUser statt getCurrentUser
            self.isLoggedIn = true
            // Direkt auf die Eigenschaften des User-Objekts zugreifen
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
}
