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

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    // Zentralisierte Instanzen
    private let auth = Auth.auth()
    private let store = Firestore.firestore()
    private let storage = Storage.storage()
    
    var currentUser: User? {
        auth.currentUser
    }
    
    private init() {}
    
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
        
        let favoriteQuoteData: [String: Any] = [
            "quoteText": quote.quote,
            "author": quote.author,
            "category": quote.category,
            "createdAt": Timestamp(date: Date())
        ]
        
        let favoriteQuoteId = "\(quote.quote)-\(quote.author)" // Eindeutige ID für Favoriten
        try await store.collection("users")
            .document(currentUser.uid)
            .collection("favorites")
            .document(favoriteQuoteId) // Dokument-ID geändert
            .setData(favoriteQuoteData)
    }
    
    func fetchFavoriteQuotes() async throws -> [Quote] {
        guard let currentUser = auth.currentUser else { return [] }
        
        let snapshot = try await store.collection("users")
            .document(currentUser.uid)
            .collection("favorites")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Quote.self)
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
}
