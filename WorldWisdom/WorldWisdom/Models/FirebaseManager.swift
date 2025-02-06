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

class FirebaseManager: ObservableObject {
    
    static let shared = FirebaseManager()
    
    // Zentralisierte Instanzen
    private let auth = Auth.auth()
    private let store = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Beobachtbare Eigenschaften
    @Published var currentUser: User? {
        didSet {
            // Optional: Aktualisiere andere Werte, wenn sich der Benutzer ändert
        }
    }
    
    private init() {
        // Initialisiere currentUser mit dem aktuellen Firebase-Benutzer
        self.currentUser = auth.currentUser
        
        // Überwache Authentifizierungsstatus-Änderungen
        _ = auth.addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                // Update currentUser, wenn sich der Authentifizierungsstatus ändert
                self.currentUser = user
            }
        }
    }
    
    // MARK: - Auth Funktionen
    
    func registerUser(email: String, password: String) async throws -> AuthDataResult {
        return try await auth.createUser(withEmail: email, password: password)
    }
    
    func loginUser(email: String, password: String) async throws -> AuthDataResult {
        return try await auth.signIn(withEmail: email, password: password)
    }
    
    func anonymousLogin() async throws -> AuthDataResult {
        return try await auth.signInAnonymously()
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    // MARK: - Firestore Funktionen
        
    func createUserInFirestore(id: String, email: String) async throws {
        let userData: [String: Any] = [
            "id": id,
            "email": email,
            "createdAt": Timestamp(date: Date())
        ]
        
        try await store.collection("users").document(id).setData(userData)
        print("Benutzer erfolgreich in Firestore gespeichert: \(email)")
    }

    func saveQuoteMetadata(quoteId: String, quoteText: String, author: String, category: String) async throws {
        let quoteData: [String: Any] = [
            "quoteText": quoteText,
            "author": author,
            "category": category,
            "createdAt": Timestamp(date: Date())
        ]
        
        try await store.collection("quotes").document(quoteId).setData(quoteData)
    }

    func fetchQuoteMetadata(quoteId: String) async throws -> [String: Any]? {
        let documentSnapshot = try await store.collection("quotes").document(quoteId).getDocument()
        return documentSnapshot.data()
    }

    // Funktionen für favorisierte Zitate

    func saveFavoriteQuote(quote: Quote) async throws {
        guard let currentUser = auth.currentUser else { return }
        
        // Speichern der Zitat-Daten als FavoriteQuote
        let favoriteQuoteData: [String: Any] = [
            "quoteText": quote.quote,
            "author": quote.author,
            "category": quote.category,
            "createdAt": Timestamp(date: Date())
        ]
        
        let favoriteQuoteId = "\(quote.quote)-\(quote.author)" // Eindeutige ID für das favorisierte Zitat
        try await store.collection("users")
            .document(currentUser.uid)
            .collection("favorites")
            .document(favoriteQuoteId)
            .setData(favoriteQuoteData)
        
        // Aktualisieren der favoriteQuoteIds im FireUser-Dokument
        let userRef = store.collection("users").document(currentUser.uid)
        try await userRef.updateData([
            "favoriteQuoteIds": FieldValue.arrayUnion([favoriteQuoteId])
        ])
    }
    
    
    func fetchFavoriteQuotes() async throws -> [Quote] {
        guard let currentUser = auth.currentUser else { return [] }

        // Abrufen der favoriteQuoteIds des Benutzers
        let userDoc = try await store.collection("users").document(currentUser.uid).getDocument()
        guard let favoriteQuoteIds = userDoc.data()?["favoriteQuoteIds"] as? [String] else {
            return []
        }

        // Abrufen der Zitate mit einer einzigen Abfrage
        let snapshot = try await store.collection("quotes")
            .whereField("id", in: favoriteQuoteIds)
            .getDocuments()

        // Umwandeln der Dokumente in Quote-Objekte
        return snapshot.documents.compactMap { document in
            let data = document.data()
            return Quote(
                id: document.documentID,
                author: data["author"] as? String ?? "Unbekannt",
                quote: data["quoteText"] as? String ?? "",
                category: data["category"] as? String ?? "Allgemein",
                tags: data["tags"] as? [String] ?? [],
                isFavorite: data["isFavorite"] as? Bool ?? false,
                description: data["description"] as? String ?? "",
                source: data["source"] as? String ?? ""
            )
        }
    }

    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async throws {
        let quoteRef = store.collection("quotes").document(quote.id)
        try await quoteRef.updateData([
            "isFavorite": isFavorite
        ])
    }

    // Löscht ein Zitat aus der Firestore-Datenbank
    func deleteFavoriteQuote(_ quote: Quote) async throws {
        do {
            // Zugriff auf Firestore und Löschen des Dokuments
            let db = Firestore.firestore()
            
            // Lösche das Zitat mit der ID aus Firestore
            try await db.collection("favoriteQuotes").document(quote.id).delete()
            
        } catch {
            // Fehlerbehandlung: Hier fangen wir alle Fehler ab
            throw NSError(domain: "com.deinProjekt.firebaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Löschen des Zitats aus der Datenbank."])
        }
    }

    func saveUserQuote(quoteText: String, author: String) async throws {
        guard let currentUser = auth.currentUser else {
            throw NSError(domain: "FirebaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kein angemeldeter Nutzer gefunden."])
        }

        let userQuoteData: [String: Any] = [
            "quoteText": quoteText,
            "author": author.isEmpty ? "Unbekannt" : author,
            "userID": currentUser.uid,
            "createdAt": Timestamp(date: Date())
        ]

        try await store.collection("users")
            .document(currentUser.uid)
            .collection("userQuotes")
            .addDocument(data: userQuoteData)
    }

    func fetchUserQuotes() async throws -> [Quote] {
        guard let currentUser = auth.currentUser else { return [] }

        let snapshot = try await store.collection("users")
            .document(currentUser.uid)
            .collection("userQuotes")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()
            return Quote(
                id: document.documentID,
                author: data["author"] as? String ?? "Unbekannt",
                quote: data["quoteText"] as? String ?? "",
                category: data["category"] as? String ?? "Allgemein",
                tags: data["tags"] as? [String] ?? [],
                isFavorite: data["isFavorite"] as? Bool ?? false,
                description: data["description"] as? String ?? "",
                source: data["source"] as? String ?? ""
            )
        }
    }

    // Methode zum Bearbeiten eines Zitats in Firestore
    func updateQuote(_ quote: Quote) async throws {
        let db = Firestore.firestore()
        let quoteRef = db.collection("quotes").document(quote.id)
        
        do {
            try await quoteRef.setData([
                "quote": quote.quote,
                "author": quote.author,
                "category": quote.category
            ], merge: true) // merge: true sorgt dafür, dass nur die geänderten Felder aktualisiert werden
        } catch {
            throw QuoteError.handleError(error)
        }
    }
    
    
    func addFavoriteQuote(_ quote: Quote) async throws {
        guard let currentUser = auth.currentUser else { return }
        
        let db = Firestore.firestore()
        // Speichern des Zitats im Benutzer-Favorites
        try db.collection("users")
            .document(currentUser.uid)
            .collection("favorites")
            .addDocument(from: quote)
        
        // die quoteId zum Benutzer-Objekt hinzufügen (favoriteQuoteIds)
        try await db.collection("users")
            .document(currentUser.uid)
            .updateData([
                "favoriteQuoteIds": FieldValue.arrayUnion([quote.id])
            ])
    }
    
    // MARK: - Storage Funktionen
    
    func uploadFile(data: Data, to path: String) async throws {
        let ref = storage.reference().child(path)
        _ = try await ref.putDataAsync(data)
    }
    
    func uploadQuoteImage(imageData: Data, quoteId: String) async throws -> String {
        let fileName = "image.png"
        let path = "quoteImages/\(quoteId)/\(fileName)"
        try await uploadFile(data: imageData, to: path)
        
        let ref = storage.reference().child(path)
        let downloadURL = try await ref.downloadURL()
        return downloadURL.absoluteString
    }
    
    func uploadQuoteFile(fileData: Data, quoteId: String) async throws -> String {
        let fileName = "quote.txt"
        let path = "quoteFiles/\(quoteId)/\(fileName)"
        try await uploadFile(data: fileData, to: path)
        
        let ref = storage.reference().child(path)
        let downloadURL = try await ref.downloadURL()
        return downloadURL.absoluteString
    }
    
    // Methode zum Löschen eines Zitats aus Firestore
    func deleteQuote(_ quote: Quote) async throws {
        let db = Firestore.firestore()
        let quoteRef = db.collection("quotes").document(quote.id)
        
        do {
            try await quoteRef.delete()
        } catch {
            throw QuoteError.handleError(error)
        }
    }
    
    
}
