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

    init() {
        Task {
            await checkCurrentUser()
        }
    }

    private func saveLoginStatus(isLoggedIn: Bool) {
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
    }

    func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    // MARK: - Validierungsfunktionen

    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    private func isValidPassword(password: String) -> Bool {
        return password.count >= 6
    }

    // MARK: - Authentifizierung

    func registerUser(email: String, password: String) async {
        guard isValidEmail(email: email) else {
            self.errorMessage = "Die E-Mail-Adresse ist ungültig."
            return
        }
        guard isValidPassword(password: password) else {
            self.errorMessage = "Das Passwort muss mindestens 6 Zeichen lang sein."
            return
        }
        
        do {
            let authResult = try await FirebaseManager.shared.registerUser(email: email, password: password)
            let newUser = FireUser(id: authResult.user.uid, email: email, name: nil, uid: authResult.user.uid, favoriteQuoteIds: [])
            
            await MainActor.run {
                self.user = newUser
                self.isLoggedIn = true
                self.saveLoginStatus(isLoggedIn: true)
            }
            
            try await FirebaseManager.shared.createUserInFirestore(id: newUser.uid, email: email)
            print("Benutzer erfolgreich registriert.")
        } catch {
            await MainActor.run {
                self.errorMessage = "Registrierung fehlgeschlagen: \(error.localizedDescription)"
            }
        }
    }

    func loginUser(email: String, password: String) async {
        guard isValidEmail(email: email), isValidPassword(password: password) else {
            self.errorMessage = "Ungültige Anmeldeinformationen."
            return
        }

        do {
            let authResult = try await FirebaseManager.shared.loginUser(email: email, password: password)
            let loggedInUser = FireUser(id: authResult.user.uid, email: email, name: nil, uid: authResult.user.uid, favoriteQuoteIds: [])
            
            self.user = loggedInUser
            self.isLoggedIn = true
            saveLoginStatus(isLoggedIn: true)
        } catch {
            self.errorMessage = "Anmeldung fehlgeschlagen: \(error.localizedDescription)"
        }
    }

    func anonymousLogin() async {
        do {
            let authResult = try await FirebaseManager.shared.anonymousLogin()
            let anonymousUser = FireUser(id: authResult.user.uid, email: nil, name: nil, uid: authResult.user.uid, favoriteQuoteIds: [])
            
            self.user = anonymousUser
            self.isLoggedIn = true
            saveLoginStatus(isLoggedIn: true)
        } catch {
            self.errorMessage = "Fehler bei der anonymen Anmeldung: \(error.localizedDescription)"
        }
    }

    // MARK: - Benutzerstatus

    func checkCurrentUser() async {
        if let currentUser = FirebaseManager.shared.currentUser {
            // Abrufen der Benutzerdaten aus Firestore (einschließlich authorId)
            let db = Firestore.firestore()
            do {
                let userDocument = try await db.collection("users").document(currentUser.uid).getDocument()
                if let data = userDocument.data() {
                    let authorId = data["authorId"] as? String ?? nil  // Holen der authorId
                    self.user = FireUser(id: currentUser.uid, email: currentUser.email, name: data["name"] as? String, uid: currentUser.uid, favoriteQuoteIds: data["favoriteQuoteIds"] as? [String] ?? [], authorId: authorId)
                    self.isLoggedIn = true
                }
            } catch {
                print("Fehler beim Abrufen der Benutzerdaten: \(error.localizedDescription)")
                self.isLoggedIn = false
                self.user = nil
            }
        } else {
            self.isLoggedIn = false
            self.user = nil
        }
    }

    func signOut() async {
        do {
            try FirebaseManager.shared.signOut()
            self.isLoggedIn = false
            saveLoginStatus(isLoggedIn: false)
            self.user = nil
        } catch {
            self.errorMessage = "Fehler beim Abmelden: \(error.localizedDescription)"
        }
    }

    // MARK: - Lieblingszitate

    func fetchFavoriteQuotes() async {
        guard let userId = user?.uid else { return }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("favoriteQuotes")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()

            let quotes = try snapshot.documents.map { document in
                try document.data(as: FavoriteQuote.self)
            }
            self.favoriteQuotes = quotes
        } catch {
            print("Fehler beim Abrufen der Zitate: \(error.localizedDescription)")
        }
    }

    // MARK: - Benutzerdaten speichern

    func saveUserData() {
        guard let userId = user?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "email": user?.email ?? "",
            "name": user?.name ?? "",
            "favoriteQuoteIds": user?.favoriteQuoteIds ?? []
        ]) { error in
            if let error = error {
                print("Fehler beim Speichern der Daten: \(error.localizedDescription)")
            } else {
                print("Daten erfolgreich gespeichert!")
            }
        }
    }
    
    
}
