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
        didSet {}
    }
    
    private init() {
        self.currentUser = auth.currentUser
        _ = auth.addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
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
    }

    func saveQuoteMetadata(quoteId: String, quoteText: String, author: String, category: String) async throws {
        let quoteData: [String: Any] = [
            "id": quoteId,
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
    
    // Update eines Zitats in Firestore
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

    // Löscht ein Zitat aus Firestore
    func deleteQuote(_ quote: Quote) async throws {
        let quoteRef = store.collection("quotes").document(quote.id)
        try await quoteRef.delete()
    }

    // MARK: - Favorisierte Zitate
    
        
    // Methode zum Abrufen der Favoriten
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
                return Quote(
                    id: document.documentID,
                    author: data["author"] as? String ?? "Unbekannt",
                    quote: data["quoteText"] as? String ?? "",
                    category: data["category"] as? String ?? "Allgemein",
                    tags: data["tags"] as? [String] ?? [],
                    isFavorite: true,
                    description: data["description"] as? String ?? "",
                    source: data["source"] as? String ?? ""
                )
            }
        } catch {
            throw error // Fehler weiterwerfen
        }
    }
    
    // Methode zum Hinzufügen eines Favoriten
    func saveFavoriteQuote(quote: Quote) async throws {
        guard let currentUser = auth.currentUser else {
            throw FavoriteError.userNotAuthenticated
        }
        
        let favoriteQuoteData: [String: Any] = [
            "id": quote.id,
            "quoteText": quote.quote,
            "author": quote.author,
            "category": quote.category,
            "createdAt": Timestamp(date: Date())
        ]
        
        do {
            try await store.collection("users")
                .document(currentUser.uid)
                .collection("favorites")
                .document(quote.id)
                .setData(favoriteQuoteData)
            
            // Aktualisiere die Liste der Favoriten-IDs
            try await store.collection("users")
                .document(currentUser.uid)
                .updateData([
                    "favoriteQuoteIds": FieldValue.arrayUnion([quote.id])
                ])
        } catch {
            throw error // Fehler weiterwerfen
        }
    }
    
    // Methode zum Löschen eines Favoriten
    func deleteFavoriteQuote(_ quote: Quote) async throws {
        guard let currentUser = auth.currentUser else { return }
        
        let userRef = store.collection("users").document(currentUser.uid)
        
        do {
            // Lösche das Zitat aus den Favoriten
            try await userRef.collection("favorites").document(quote.id).delete()
            
            // Entferne die ID aus der Liste der Favoriten
            try await userRef.updateData([
                "favoriteQuoteIds": FieldValue.arrayRemove([quote.id])
            ])
        } catch {
            throw error // Fehler weiterwerfen
        }
    }
    
    // Methode zum Aktualisieren des Favoritenstatus
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async throws {
        let quoteRef = store.collection("quotes").document(quote.id)
        do {
            try await quoteRef.updateData([
                "isFavorite": isFavorite
            ])
        } catch {
            throw error // Fehler weiterwerfen
        }
    }
    

    // MARK: - Benutzerdefinierte Zitate
    
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

        print("Speichern des Zitats in Firestore: \(userQuoteData)")
        
        do {
            try await store.collection("users")
                .document(currentUser.uid)
                .collection("userQuotes")
                .addDocument(data: userQuoteData)
            print("Zitat erfolgreich in Firestore gespeichert.")
        } catch {
            print("Fehler beim Speichern des Zitats in Firestore: \(error.localizedDescription)")
            throw error
        }
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
                isFavorite: false,
                description: data["description"] as? String ?? "",
                source: data["source"] as? String ?? ""
            )
        }
    }
    
    func updateUserQuote(id: String, newText: String, newAuthor: String) async throws {
        guard let currentUser = auth.currentUser else {
            throw NSError(domain: "FirebaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kein angemeldeter Nutzer gefunden."])
        }

        let updatedData: [String: Any] = [
            "quoteText": newText,
            "author": newAuthor.isEmpty ? "Unbekannt" : newAuthor,
            "updatedAt": Timestamp(date: Date())
        ]

        try await store.collection("users")
            .document(currentUser.uid)
            .collection("userQuotes")
            .document(id)
            .updateData(updatedData)
    }
    
    

    // MARK: - Storage Funktionen
    
    func uploadFile(data: Data, to path: String) async throws {
        let ref = storage.reference().child(path)
        _ = try await ref.putDataAsync(data)
    }
    
    func uploadQuoteImage(imageData: Data, quoteId: String) async throws -> String {
        let fileName = "quoteImages/\(quoteId).jpg"
        let ref = storage.reference().child(fileName)
        _ = try await ref.putDataAsync(imageData)
        return try await ref.downloadURL().absoluteString
    }
}
