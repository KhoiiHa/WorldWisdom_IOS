//
//  FirebaseManager.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 21.01.25.
//

import FirebaseAuth
import Foundation
import FirebaseFirestore

class FirebaseManager {

    static let shared = FirebaseManager() 

    private init() {}

    // Funktion zur Benutzerregistrierung
    func registerUser(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().createUser(withEmail: email, password: password)
    }

    // Funktion zur Benutzeranmeldung
    func loginUser(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().signIn(withEmail: email, password: password)
    }

    // Funktion zur anonymer Anmeldung
    func anonymousLogin() async throws -> AuthDataResult {
        return try await Auth.auth().signInAnonymously()
    }

    // Funktion, um den aktuellen Benutzer zu holen
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }

    // Funktion zum Abmelden
    func signOut() throws {
        try Auth.auth().signOut()
    }

    // Funktion zum Speichern der Benutzerdaten in Firestore
    func createUserInFirestore(id: String, email: String) async throws {
        let databank = Firestore.firestore()
        let userData: [String: Any] = [
            "email": email,
            "createdAt": Timestamp(date: Date())
        ]
        try await databank.collection("users").document(id).setData(userData)
    }

    // Funktion zum Abrufen der Benutzerdaten aus Firestore
    func fetchUserFromFirestore(id: String) async throws -> FireUser? {
        let databank = Firestore.firestore()
        let userDocument = try await databank.collection("users").document(id).getDocument()

        if let userData = userDocument.data(), let email = userData["email"] as? String {
            return FireUser(id: id, email: email, uid: id)
        }
        return nil
    }
}
