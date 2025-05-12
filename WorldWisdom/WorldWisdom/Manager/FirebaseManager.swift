//
//  FirebaseManager.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 21.01.25.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Firebase

/// Zentraler Manager für Firebase Authentication, Firestore und Storage-Funktionen

// MARK: - FirebaseManager

class FirebaseManager: ObservableObject {
    
    static let shared = FirebaseManager()
    
    // Zentralisierte Instanzen
    private let auth = Auth.auth()
    private let store = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Beobachtbare Eigenschaften
    @Published var currentUser: User? {
        didSet {}
    }
    
    var isUserLoggedIn: Bool {
        return auth.currentUser != nil
    }
    
    // MARK: - Initialisierung
    
    private init() {
        self.currentUser = auth.currentUser
        _ = auth.addStateDidChangeListener { _, user in
            Task {
                await MainActor.run {
                    self.currentUser = user
                }
            }
        }
    }
    
    // MARK: - Authentifizierung
    
    /// Registriert einen neuen Benutzer mit E-Mail und Passwort
    func registerUser(email: String, password: String) async throws -> AuthDataResult {
        return try await auth.createUser(withEmail: email, password: password)
    }
    
    /// Meldet einen Benutzer mit E-Mail und Passwort an
    func loginUser(email: String, password: String) async throws -> AuthDataResult {
        return try await auth.signIn(withEmail: email, password: password)
    }
    
    /// Meldet einen Benutzer anonym an und legt einen Firestore-Datensatz an, falls noch nicht vorhanden
    func anonymousLogin() async throws -> AuthDataResult {
        let result = try await auth.signInAnonymously()
        let uid = result.user.uid
        let userRef = store.collection("users").document(uid)
        
        let doc = try await userRef.getDocument()
        if !doc.exists {
            try await userRef.setData([
                "id": uid
            ])
        }
        
        return result
    }
    
    /// Meldet den aktuellen Benutzer ab
    func signOut() throws {
        try auth.signOut()
    }
    
    /// Meldet den aktuellen Benutzer ab und startet eine anonyme Anmeldung
    func signOutAndStartAnonymously() async throws {
        try signOut()
        _ = try await anonymousLogin()
    }
    
    // MARK: - Zitatverwaltung
    
    /// Legt einen neuen Benutzer in Firestore mit ID und E-Mail an
    func createUserInFirestore(id: String, email: String) async throws {
        let userData: [String: Any] = [
            "id": id,
            "email": email
        ]
        try await store.collection("users").document(id).setData(userData)
    }
    
    /// Speichert Metadaten eines Zitats in Firestore
    func saveQuoteMetadata(quoteId: String, quoteText: String, author: String, category: String, authorImageURL: String) async throws {
        let quoteData: [String: Any] = [
            "id": quoteId,
            "quoteText": quoteText,
            "author": author,
            "category": category,
            "authorImageURL": authorImageURL
        ]
        try await store.collection("quotes").document(quoteId).setData(quoteData)
    }

    /// Lädt Metadaten eines Zitats aus Firestore
    func fetchQuoteMetadata(quoteId: String) async throws -> [String: Any]? {
        do {
            let documentSnapshot = try await store.collection("quotes").document(quoteId).getDocument()
            return documentSnapshot.data()
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain {
                throw FirebaseError.unknownError("Netzwerkfehler: Überprüfe deine Internetverbindung oder Mockoon-Server")
            } else {
                throw FirebaseError.unknownError(error.localizedDescription)
            }
        }
    }
    
    /// Aktualisiert ein bestehendes Zitat in Firestore
    func updateQuote(_ quote: Quote) async throws {
        let quoteRef = store.collection("quotes").document(quote.id)
        try await quoteRef.updateData([
            "quoteText": quote.quote,
            "author": quote.author,
            "category": quote.category,
            "tags": quote.tags,
            "description": quote.description,
            "source": quote.source
        ])
    }
    
    /// Löscht ein Zitat aus Firestore
    func deleteQuote(_ quote: Quote) async throws {
        let quoteRef = store.collection("quotes").document(quote.id)
        try await quoteRef.delete()
    }
    
    // MARK: - Favoritenverwaltung
    
    /// Lädt alle favorisierten Zitate des aktuellen Benutzers
    func fetchFavoriteQuotes() async throws -> [Quote] {
        guard let currentUser = auth.currentUser else {
            throw FavoriteError.userNotAuthenticated
        }
        
        do {
            let snapshot = try await store.collection("users")
                .document(currentUser.uid)
                .collection("favorites")
                .getDocuments()
            
            return snapshot.documents.compactMap { document in
                let data = document.data()
                let authorImageURLs = data["authorImageURLs"] as? [String] ?? []
                
                return Quote(
                    id: document.documentID,
                    author: data["author"] as? String ?? "Unbekannt",
                    quote: data["quoteText"] as? String ?? "",
                    category: data["category"] as? String ?? "Allgemein",
                    tags: data["tags"] as? [String] ?? [],
                    isFavorite: true,
                    description: data["description"] as? String ?? "",
                    source: data["source"] as? String ?? "",
                    authorImageURLs: authorImageURLs
                )
            }
        } catch {
            throw FirebaseError.unknownError(error.localizedDescription)
        }
    }

    /// Speichert ein Zitat als Favorit für den aktuellen Benutzer
    func saveFavoriteQuote(quote: Quote) async throws {
        guard let currentUser = auth.currentUser else {
            throw FavoriteError.userNotAuthenticated
        }

        let favoriteQuoteData: [String: Any] = [
            "id": quote.id,
            "quoteText": quote.quote,
            "author": quote.author,
            "category": quote.category,
            "tags": quote.tags,
            "description": quote.description,
            "source": quote.source,
            "authorImageURLs": quote.authorImageURLs ?? []
        ]

        let userRef = store.collection("users").document(currentUser.uid)
        let favoriteQuoteRef = userRef.collection("favorites").document(quote.id)

        do {
            let documentSnapshot = try await favoriteQuoteRef.getDocument()
            if documentSnapshot.exists {
                throw FavoriteError.favoriteAlreadyExists
            }

            try await favoriteQuoteRef.setData(favoriteQuoteData)
            try await updateFavoriteQuoteIds(for: currentUser.uid, quoteId: quote.id, add: true)
        } catch {
            throw FirebaseError.unknownError(error.localizedDescription)
        }
    }
    
    /// Aktualisiert die Liste der Favoriten-IDs im Benutzer-Dokument
    private func updateFavoriteQuoteIds(for userId: String, quoteId: String, add: Bool) async throws {
        let userRef = store.collection("users").document(userId)
        
        do {
            try await userRef.setData([
                "favoriteQuoteIds": add ? FieldValue.arrayUnion([quoteId]) : FieldValue.arrayRemove([quoteId])
            ], merge: true)
        } catch let error as NSError {
            throw FirebaseError.unknownError(error.localizedDescription)
        }
    }
    
    /// Löscht ein favorisiertes Zitat des aktuellen Benutzers
    func deleteFavoriteQuote(_ quote: Quote) async throws {
        guard let currentUser = auth.currentUser else {
            throw FavoriteError.userNotAuthenticated
        }

        let userRef = store.collection("users").document(currentUser.uid)
        let favoriteQuoteRef = userRef.collection("favorites").document(quote.id)

        do {
            try await favoriteQuoteRef.delete()
            try await updateFavoriteQuoteIds(for: currentUser.uid, quoteId: quote.id, add: false)

            let quoteRef = store.collection("quotes").document(quote.id)
            let quoteDoc = try await quoteRef.getDocument()

            if quoteDoc.exists {
                try await quoteRef.updateData(["isFavorite": false])
            }
        } catch let error as NSError {
            throw FirebaseError.unknownError(error.localizedDescription)
        }
    }
    
    /// Aktualisiert den Favoritenstatus eines Zitats
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async throws {
        guard auth.currentUser != nil else {
            throw FavoriteError.userNotAuthenticated
        }

        let quoteRef = store.collection("quotes").document(quote.id)

        do {
            try await quoteRef.updateData(["isFavorite": isFavorite])
        } catch {
            throw FirebaseError.unknownError(error.localizedDescription)
        }
    }
    
    // MARK: - Wartung & Cleanup
    
    /// Löscht alle Favoriten des aktuellen Benutzers in Firebase
    func deleteAllFavoriteQuotes() async throws {
        guard let currentUser = auth.currentUser else {
            throw FavoriteError.userNotAuthenticated
        }

        let userRef = store.collection("users").document(currentUser.uid)
        let favoritesRef = userRef.collection("favorites")

        let snapshot = try await favoritesRef.getDocuments()

        for document in snapshot.documents {
            try await favoritesRef.document(document.documentID).delete()
        }

        // Leere auch die Referenzliste der Favoriten im User-Dokument (optional)
        try await userRef.updateData(["favoriteQuoteIds": []])
    }
}
