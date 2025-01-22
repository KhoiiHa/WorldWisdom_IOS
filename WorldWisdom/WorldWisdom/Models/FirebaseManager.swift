//
//  FirebaseManager.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 21.01.25.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {

    static let shared = FirebaseManager()

    // Zentralisierte Instanzen
    private let auth = Auth.auth()
    let store = Firestore.firestore()
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

    // Zitat-Metadaten speichern (Text, Autor, Kategorie) in Firestore
    func saveQuoteMetadata(quoteId: String, quoteText: String, author: String, category: String) async throws {
        let quoteData: [String: Any] = [
            "quoteText": quoteText,
            "author": author,
            "category": category,
            "createdAt": Timestamp(date: Date())
        ]
        
        // Speichern der Zitat-Daten in Firestore unter der Sammlung 'quotes'
        try await store.collection("quotes").document(quoteId).setData(quoteData)
    }

    // Zitat-Metadaten aus Firestore holen
    func fetchQuoteMetadata(quoteId: String) async throws -> [String: Any]? {
        let documentSnapshot = try await store.collection("quotes").document(quoteId).getDocument()
        return documentSnapshot.data()
    }

    // Funktionen für favorisierte Zitate
    func saveFavoriteQuote(quote: Quote) async throws {
        guard let currentUser = auth.currentUser else { return }
        
        let favoriteQuoteData: [String: Any] = [
            "quoteText": quote.quoteText,
            "author": quote.author,
            "category": quote.category ?? "Uncategorized",
            "createdAt": Timestamp(date: Date())
        ]
        
        // Speichern des favorisierten Zitats in der Sammlung 'favorites' für den aktuellen Nutzer
        try await store.collection("users")
            .document(currentUser.uid)
            .collection("favorites")
            .document(quote.quoteText) // Speichern mit dem Text des Zitats als Dokument-ID
            .setData(favoriteQuoteData)
    }

    func fetchFavoriteQuotes() async throws -> [Quote]? {
        guard let currentUser = auth.currentUser else { return nil }
        
        // Abrufen der favorisierten Zitate des aktuellen Nutzers aus Firestore
        let snapshot = try await store.collection("users")
            .document(currentUser.uid)
            .collection("favorites")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Quote.self)
        }
    }

    // MARK: - Storage Funktionen

    // Funktion zum Hochladen einer Datei in Firebase Storage
    func uploadFile(data: Data, to path: String) async throws {
        let ref = storage.reference().child(path)
        _ = try await ref.putDataAsync(data)
    }

    // Funktion zum Hochladen eines Zitatbildes und Abrufen der Download-URL
    func uploadQuoteImage(imageData: Data, quoteId: String) async throws -> String {
        let fileName = "image.png" // Beispiel-Dateiname für das Bild
        let path = "quoteImages/\(quoteId)/\(fileName)" // Definierter Speicherpfad
        try await uploadFile(data: imageData, to: path)
        
        // Hole den Download-URL des hochgeladenen Bildes
        let ref = storage.reference().child(path)
        let downloadURL = try await ref.downloadURL()
        return downloadURL.absoluteString // Rückgabe des Download-Links
    }
    
    // Funktion zum Hochladen einer Zitat-Datei (z.B. Text) und Abrufen der Download-URL
    func uploadQuoteFile(fileData: Data, quoteId: String) async throws -> String {
        let fileName = "quote.txt" // Beispiel-Dateiname für die Zitat-Datei
        let path = "quoteFiles/\(quoteId)/\(fileName)" // Speicherpfad für Zitat-Datei
        try await uploadFile(data: fileData, to: path)
        
        // Hole den Download-URL der hochgeladenen Datei
        let ref = storage.reference().child(path)
        let downloadURL = try await ref.downloadURL()
        return downloadURL.absoluteString // Rückgabe des Download-Links
    }
}
