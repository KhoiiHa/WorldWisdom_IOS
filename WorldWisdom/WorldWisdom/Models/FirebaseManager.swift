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
        return auth.currentUser
    }

    private init() {}

    // MARK: - Auth Funktionen

    func registerUser(email: String, password: String) async throws -> AuthDataResult {
        do {
            return try await auth.createUser(withEmail: email, password: password)
        } catch let error as NSError {
            throw AuthError.handleFirebaseError(error)
        }
    }

    func loginUser(email: String, password: String) async throws -> AuthDataResult {
        do {
            return try await auth.signIn(withEmail: email, password: password)
        } catch let error as NSError {
            throw AuthError.handleFirebaseError(error)
        }
    }

    func anonymousLogin() async throws -> AuthDataResult {
        do {
            return try await auth.signInAnonymously()
        } catch let error as NSError {
            throw AuthError.handleFirebaseError(error)
        }
    }

    func signOut() throws {
        do {
            try auth.signOut()
        } catch let error as NSError {
            throw AuthError.handleFirebaseError(error)
        }
    }

    // MARK: - Firestore Funktionen
    
    func createUserInFirestore(id: String, email: String) async throws {
        let userData: [String: Any] = [
            "id": id,
            "email": email,
            "createdAt": Timestamp(date: Date())
        ]
        
        do {
            try await store.collection("users").document(id).setData(userData)
            print("Benutzer erfolgreich in Firestore gespeichert: \(email)")
        } catch let error as NSError {
            throw QuoteError.handleError(error)
        }
    }

    func saveQuoteMetadata(quoteId: String, quoteText: String, author: String, category: String) async throws {
        let quoteData: [String: Any] = [
            "quoteText": quoteText,
            "author": author,
            "category": category,
            "createdAt": Timestamp(date: Date())
        ]
        
        do {
            try await store.collection("quotes").document(quoteId).setData(quoteData)
        } catch let error as NSError {
            throw QuoteError.handleError(error)
        }
    }

    func fetchQuoteMetadata(quoteId: String) async throws -> [String: Any]? {
        do {
            let documentSnapshot = try await store.collection("quotes").document(quoteId).getDocument()
            return documentSnapshot.data()
        } catch let error as NSError {
            throw QuoteError.handleError(error)
        }
    }

    // Funktionen für favorisierte Zitate
    func saveFavoriteQuote(quote: Quote) async throws {
        guard let currentUser = auth.currentUser else { return }

        let favoriteQuoteData: [String: Any] = [
            "quoteText": quote.quote, // Hier 'quote' verwenden
            "author": quote.author,
            "category": quote.category,
            "createdAt": Timestamp(date: Date())
        ]
        
        do {
            try await store.collection("users")
                .document(currentUser.uid)
                .collection("favorites")
                .document(quote.quote)
                .setData(favoriteQuoteData)
        } catch let error as NSError {
            throw QuoteError.handleError(error)
        }
    }

    func fetchFavoriteQuotes() async throws -> [Quote]? {
        guard let currentUser = auth.currentUser else { return nil }
        
        do {
            let snapshot = try await store.collection("users")
                .document(currentUser.uid)
                .collection("favorites")
                .getDocuments()

            return snapshot.documents.compactMap { document in
                var quote = try? document.data(as: Quote.self)
                quote?.isFavorite = true // Wir markieren es als Favorit
                return quote
            }
        } catch let error as NSError {
            throw QuoteError.handleError(error)
        }
    }

    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async throws {
        let quoteRef = store.collection("quotes").document(quote.id)
        
        do {
            try await quoteRef.updateData(["isFavorite": isFavorite])
        } catch let error as NSError {
            throw QuoteError.handleError(error)
        }
    }

    // MARK: - Storage Funktionen

    func uploadFile(data: Data, to path: String) async throws {
        let ref = storage.reference().child(path)
        do {
            _ = try await ref.putDataAsync(data)
        } catch let error as NSError {
            throw QuoteError.handleError(error)
        }
    }

    func uploadQuoteImage(imageData: Data, quoteId: String) async throws -> String {
        let fileName = "image.png" // Beispiel-Dateiname für das Bild
        let path = "quoteImages/\(quoteId)/\(fileName)"
        
        try await uploadFile(data: imageData, to: path)

        let ref = storage.reference().child(path)
        do {
            let downloadURL = try await ref.downloadURL()
            return downloadURL.absoluteString
        } catch let error as NSError {
            throw QuoteError.handleError(error)
        }
    }

    func uploadQuoteFile(fileData: Data, quoteId: String) async throws -> String {
        let fileName = "quote.txt" // Beispiel-Dateiname für die Zitat-Datei
        let path = "quoteFiles/\(quoteId)/\(fileName)"
        
        try await uploadFile(data: fileData, to: path)

        let ref = storage.reference().child(path)
        do {
            let downloadURL = try await ref.downloadURL()
            return downloadURL.absoluteString
        } catch let error as NSError {
            throw QuoteError.handleError(error)
        }
    }
}
