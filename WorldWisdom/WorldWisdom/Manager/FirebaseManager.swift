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
            Task {
                await MainActor.run {
                    self.currentUser = user
                }
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
    
    func saveQuoteMetadata(quoteId: String, quoteText: String, author: String, category: String, authorImageURL: String) async throws {
        let quoteData: [String: Any] = [
            "id": quoteId,
            "quoteText": quoteText,
            "author": author,
            "category": category,
            "authorImageURL": authorImageURL, // Bild-URL hinzufügen
            "createdAt": Timestamp(date: Date())
        ]
        try await store.collection("quotes").document(quoteId).setData(quoteData)
    }

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
    
    func deleteQuote(_ quote: Quote) async throws {
        let quoteRef = store.collection("quotes").document(quote.id)
        try await quoteRef.delete()
    }
    
    // MARK: - Favorisierte Zitate
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
                let authorImageURL = data["authorImageURL"] as? String ?? ""
                return Quote(
                    id: document.documentID,
                    author: data["author"] as? String ?? "Unbekannt",
                    quote: data["quoteText"] as? String ?? "",
                    category: data["category"] as? String ?? "Allgemein",
                    tags: data["tags"] as? [String] ?? [],
                    isFavorite: true,
                    description: data["description"] as? String ?? "",
                    source: data["source"] as? String ?? "",
                    authorImageURL: authorImageURL
                )
            }
        } catch {
            throw FirebaseError.unknownError(error.localizedDescription)
        }
    }

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
    
    private func updateFavoriteQuoteIds(for userId: String, quoteId: String, add: Bool) async throws {
        let userRef = store.collection("users").document(userId)
        
        do {
            try await userRef.updateData([
                "favoriteQuoteIds": add ? FieldValue.arrayUnion([quoteId]) : FieldValue.arrayRemove([quoteId])
            ])
        } catch let error as NSError {
            throw FirebaseError.unknownError(error.localizedDescription)
        }
    }
    
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
    
    // MARK: - Benutzerdefinierte Zitate
    func saveUserQuote(quoteText: String, author: String, authorImageURL: String) async throws {
        guard let currentUser = auth.currentUser else {
            throw FirebaseError.noAuthenticatedUser
        }

        let userQuoteData: [String: Any] = [
            "quoteText": quoteText,
            "author": author.isEmpty ? "Unbekannt" : author,
            "authorImageURL": authorImageURL, // authorImageURL speichern
            "userID": currentUser.uid,
            "createdAt": Timestamp(date: Date())
        ]

        do {
            try await store.collection("users")
                .document(currentUser.uid)
                .collection("userQuotes")
                .addDocument(data: userQuoteData)
        } catch {
            throw FirebaseError.unknownError(error.localizedDescription)
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
                source: data["source"] as? String ?? "",
                authorImageURL: data["authorImageURL"] as? String ?? "" // fetchen der URL
            )
        }
    }
    
    func updateUserQuote(id: String, quoteText: String, author: String, authorImageURL: String) async throws {
        guard let currentUser = auth.currentUser else {
            throw FirebaseError.noAuthenticatedUser
        }

        let userQuoteData: [String: Any] = [
            "quoteText": quoteText,
            "author": author.isEmpty ? "Unbekannt" : author,
            "authorImageURL": authorImageURL, // authorImageURL speichern
            "updatedAt": Timestamp(date: Date()) // Aktualisierungszeit
        ]

        do {
            try await store.collection("users")
                .document(currentUser.uid)
                .collection("userQuotes")
                .document(id) // Das Zitat anhand der ID finden und aktualisieren
                .updateData(userQuoteData)
        } catch {
            throw FirebaseError.unknownError(error.localizedDescription)
        }
    }
    
    // MARK: - Firebase Storage - Autorenbilder hochladen
    
    // 📌 Bilder aus Firebase Storage abrufen
    func fetchImages(for authorId: String, completion: @escaping (Result<[String], FirebaseError>) -> Void) {
        let storageRef = Storage.storage().reference().child("author_images/\(authorId)")
        
        storageRef.listAll { result in
            switch result {
            case .success(let storageListResult):
                var urls: [String] = []
                let group = DispatchGroup()
                
                for item in storageListResult.items {
                    group.enter()
                    item.downloadURL { url, error in
                        if let error = error {
                            print("Fehler beim Abrufen der URL für \(item.name): \(error.localizedDescription)")
                            group.leave()
                            return
                        }
                        if let url = url {
                            urls.append(url.absoluteString)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    if urls.isEmpty {
                        completion(.failure(.imageDownloadFailed))
                    } else {
                        completion(.success(urls))
                    }
                }
            case .failure(let error):
                print("Fehler beim Abrufen der Bilder: \(error.localizedDescription)")
                completion(.failure(.fetchFailed))
            }
        }
    }
    
    // 📌 Bild in Firebase hochladen (mit async/await)
    func uploadAuthorImage(image: UIImage, authorId: String) async throws -> String {
        // Stelle sicher, dass das Bild in Daten umgewandelt wird
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw FirebaseError.authorImageUploadFailed
        }

        // Erstelle den Referenzpfad für das Bild in Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference().child("authors/\(authorId).jpg")

        // Lade das Bild hoch und erhalte die URL
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            storageRef.putData(imageData, metadata: nil) { _, error in
                if error != nil {  // Prüfen, ob ein Fehler aufgetreten ist
                    continuation.resume(throwing: FirebaseError.uploadFailed)
                    return
                }

                // Erfolgreicher Upload -> Lade die URL
                storageRef.downloadURL { url, _ in
                    if let url = url {
                        print("✅ Bild erfolgreich hochgeladen: \(url.absoluteString)")
                        continuation.resume(returning: url.absoluteString) // Rückgabe der URL hier
                    } else {
                        continuation.resume(throwing: FirebaseError.imageDownloadFailed)
                    }
                }
            }
        }
    }
}
