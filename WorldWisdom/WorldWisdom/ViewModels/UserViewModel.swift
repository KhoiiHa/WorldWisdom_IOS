//
//  UserViewModel.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 16.01.25.
//

import SwiftUI
import FirebaseAuth
import Foundation

@MainActor
class UserViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
    @Published var user: User? // Speichern der Benutzerinformation
    
    // Funktion für die Registrierung mit E-Mail und Passwort
    func registerUser(email: String, password: String) async {
        do {
            // Firebase-Registrierung mit async/await
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            self.isLoggedIn = true
            self.user = authResult.user // Benutzerdaten speichern
            print("Benutzer erfolgreich registriert. UID: \(user?.uid ?? "Unbekannt")")
        } catch let error as NSError {
            // Fehlerbehandlung anhand des Firebase-Fehlers
            self.errorMessage = self.getErrorMessage(error: error)
            print(self.errorMessage ?? "Unbekannter Fehler")
        }
    }

    // Funktion für die Anmeldung mit E-Mail und Passwort
    func loginUser(email: String, password: String) async {
        do {
            // Firebase-Anmeldung mit async/await
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            self.isLoggedIn = true
            self.user = authResult.user // Benutzerdaten speichern
            print("Benutzer erfolgreich angemeldet. UID: \(user?.uid ?? "Unbekannt")")
        } catch let error as NSError {
            // Fehlerbehandlung anhand des Firebase-Fehlers
            self.errorMessage = self.getErrorMessage(error: error)
            print(self.errorMessage ?? "Unbekannter Fehler")
        }
    }
    
    // Funktion, um beim Start zu prüfen, ob der Benutzer bereits angemeldet ist
    func checkCurrentUser() {
        if let currentUser = Auth.auth().currentUser {
            self.isLoggedIn = true
            self.user = currentUser
            print("Aktueller Benutzer: \(currentUser.email ?? "Unbekannt")")
        } else {
            self.isLoggedIn = false
            self.user = nil
            print("Kein Benutzer angemeldet.")
        }
    }

    // Funktion für anonyme Anmeldung
    func anonymousLogin() async {
        do {
            // Anonyme Anmeldung mit async/await
            let authResult = try await Auth.auth().signInAnonymously()
            self.isLoggedIn = true
            self.user = authResult.user // Benutzerdaten speichern
            print("Anonyme Anmeldung erfolgreich. UID: \(user?.uid ?? "Unbekannt")")
        } catch let error as NSError {
            // Fehlerbehandlung anhand des Firebase-Fehlers
            self.errorMessage = self.getErrorMessage(error: error)
            print(self.errorMessage ?? "Unbekannter Fehler")
        }
    }

    // Fehlerbehandlungsfunktion für Firebase Fehler
    private func getErrorMessage(error: NSError) -> String {
        switch error.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Die E-Mail-Adresse wird bereits verwendet."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Die E-Mail-Adresse ist ungültig."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Falsches Passwort."
        case AuthErrorCode.userNotFound.rawValue:
            return "Benutzer nicht gefunden."
        default:
            return "Unbekannter Fehler."
        }
    }
}
