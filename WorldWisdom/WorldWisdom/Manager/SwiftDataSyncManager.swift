//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import Foundation
import SwiftData
import FirebaseFirestore
import FirebaseStorage

@MainActor
class SwiftDataSyncManager {

    private var container: ModelContainer

    internal var context: ModelContext {
        return container.mainContext
    }

    init() {
        do {
            self.container = try ModelContainer(for: QuoteEntity.self, configurations: ModelConfiguration())
        } catch {
            fatalError("Fehler beim Initialisieren des ModelContainers: \(error.localizedDescription)")
        }
    }

    
    // Fügt ein Zitat hinzu oder aktualisiert es (mit optionalem Bild)
    func addOrUpdateQuote(quoteEntity: QuoteEntity, image: UIImage?) async throws {
        let firestore = Firestore.firestore()
        let quotesCollection = firestore.collection("quotes")

        var imageUrl: String?

        // Wenn ein Bild vorhanden ist, lade es in Firebase Storage hoch
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("authorImages/\(quoteEntity.id).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            // Lade das Bild hoch und erhalte den Download-Link
            imageUrl = try await uploadImageToFirebaseStorage(storageRef: storageRef, imageData: imageData, metadata: metadata)
        }

        // Überprüfen, ob es sich um ein bestehendes Zitat handelt (getDocument ist asynchron)
        let documentSnapshot = try await quotesCollection.document(quoteEntity.id).getDocument()

        if documentSnapshot.exists {
            // Falls das Dokument bereits existiert, aktualisiere es
            try await quotesCollection.document(quoteEntity.id).setData([
                "author": quoteEntity.author,
                "quote": quoteEntity.quote,
                "category": quoteEntity.category,
                "tags": quoteEntity.tags ?? [],
                "isFavorite": quoteEntity.isFavorite,
                "description": quoteEntity.quoteDescription,
                "source": quoteEntity.source,
                "authorImageURL": imageUrl ?? quoteEntity.authorImageURL ?? ""  // Falls kein Bild hochgeladen wurde, das bestehende URL verwenden
            ])
        } else {
            // Falls das Dokument nicht existiert, füge es als neues Zitat hinzu
            try await quotesCollection.document(quoteEntity.id).setData([
                "author": quoteEntity.author,
                "quote": quoteEntity.quote,
                "category": quoteEntity.category,
                "tags": quoteEntity.tags ?? [],
                "isFavorite": quoteEntity.isFavorite,
                "description": quoteEntity.quoteDescription,
                "source": quoteEntity.source,
                "authorImageURL": imageUrl ?? quoteEntity.authorImageURL ?? ""  // Hier auch optionalen Wert behandeln
            ])
        }
    }

    // Fügt nur ein neues Zitat hinzu, ohne nach vorhandenen zu suchen
    func addQuote(_ quote: Quote) async throws {
        _ = quote.tags.joined(separator: ", ")

        let newQuote = QuoteEntity(
            id: quote.id,
            author: quote.author,
            quote: quote.quote,
            category: quote.category,
            tags: quote.tags,
            isFavorite: quote.isFavorite,
            quoteDescription: quote.description,
            source: quote.source,
            authorImageURL: quote.authorImageURL, // Standardwert falls nil
            authorImageData: nil
        )
        context.insert(newQuote)

        do {
            try context.save() // Änderungen speichern
        } catch {
            throw SwiftDataError.saveError
        }
    }

    // Entfernt ein Zitat aus den Favoriten
    func removeFavoriteQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        
        do {
            let quoteEntities = try context.fetch(fetchRequest)

            if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
                existingQuote.isFavorite = false
                try context.save()
            }
        } catch {
            throw SwiftDataError.saveError
        }
    }

    // Lädt die Favoriten aus SwiftData
    func fetchFavoriteQuotes() async throws -> [Quote] {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        
        do {
            let quoteEntities = try context.fetch(fetchRequest)

            return quoteEntities.filter { $0.isFavorite }.map { entity in
                Quote(
                    id: entity.id,
                    author: entity.author,
                    quote: entity.quote,
                    category: entity.category,
                    tags: entity.tags ?? [], 
                    isFavorite: entity.isFavorite,
                    description: entity.quoteDescription,
                    source: entity.source,
                    // Optionales Feld 'authorImageURL' hinzugefügt
                    authorImageURL: entity.authorImageURL ?? "" // Standardwert falls nil
                )
            }
        } catch {
            throw SwiftDataError.fetchError
        }
    }

    // Löscht ein Zitat
    func deleteQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        
        do {
            let quoteEntities = try context.fetch(fetchRequest)

            if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
                context.delete(existingQuote)
                try context.save()
            }
        } catch {
            throw SwiftDataError.deleteError
        }
    }

    // Synchronisiert die Zitate aus Firestore mit SwiftData
    func syncQuotesFromFirestore() async {
        do {
            let firestoreQuotes = try await fetchQuotesFromFirestore()

            for quote in firestoreQuotes {
                var updatedQuote = quote

                // Wenn authorImageURL vorhanden ist, lade das Bild hoch
                if let authorImageURLString = updatedQuote.authorImageURL,
                   let authorImageURL = URL(string: authorImageURLString),
                   let imageData = try? Data(contentsOf: authorImageURL),
                   let image = UIImage(data: imageData) {

                    // Lade das Bild in Firebase Storage hoch
                    let storage = Storage.storage()
                    let storageRef = storage.reference().child("authors/\(updatedQuote.id).jpg")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"

                    // Hochladen des Bildes
                    let uploadedImageURL = try await uploadImageToFirebaseStorage(storageRef: storageRef, imageData: imageData, metadata: metadata)

                    // Aktualisiere URL in den Zitatdaten
                    updatedQuote.authorImageURL = uploadedImageURL

                    // Erstelle das QuoteEntity-Objekt und speichere das Bild in SwiftData
                    let quoteEntity = QuoteEntity.fromFirebaseModel(quote: updatedQuote)
                    quoteEntity.authorImageData = imageData

                    // Speichern in SwiftData
                    try await addOrUpdateQuote(quoteEntity: quoteEntity, image: image)
                } else {
                    // Kein Bild, speichere nur das Zitat
                    let quoteEntity = QuoteEntity.fromFirebaseModel(quote: updatedQuote)
                    try await addOrUpdateQuote(quoteEntity: quoteEntity, image: nil)
                }
            }

            print("✅ Firestore-Zitate erfolgreich mit SwiftData synchronisiert.")
        } catch {
            print("❌ Fehler beim Synchronisieren von Firestore: \(error.localizedDescription)")
        }
    }
    
    private func fetchQuotesFromFirestore() async throws -> [Quote] {
        let firestore = Firestore.firestore()
        let quotesCollection = firestore.collection("quotes")

        do {
            let snapshot = try await quotesCollection.getDocuments()

            return snapshot.documents.compactMap { document in
                let data = document.data()

                guard
                    let id = document.documentID as String?,
                    let author = data["author"] as? String,
                    let quote = data["quote"] as? String,
                    let category = data["category"] as? String,
                    let isFavorite = data["isFavorite"] as? Bool,
                    let tags = data["tags"] as? [String],
                    let description = data["description"] as? String,
                    let source = data["source"] as? String
                else {
                    print("❌ Fehler: Ungültige Daten für Dokument \(document.documentID)")
                    return Quote(
                        id: "",
                        author: "Unbekannt",
                        quote: "Unbekannt",
                        category: "",
                        tags: [],
                        isFavorite: false,
                        description: "",
                        source: "",
                        authorImageURL: ""
                    )
                }

                // Hole die authorImageURL aus Firestore-Daten
                let authorImageURL = data["authorImageURL"] as? String ?? ""
                
                return Quote(
                    id: id,
                    author: author,
                    quote: quote,
                    category: category,
                    tags: tags,
                    isFavorite: isFavorite,
                    description: description,
                    source: source,
                    authorImageURL: authorImageURL
                )
            }
        } catch {
            throw SwiftDataError.fetchError
        }
    }
    
    
    // Aktualisiert den Favoritenstatus eines Zitats
    func updateFavoriteStatus(for quote: Quote, to isFavorite: Bool) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()

        do {
            let quoteEntities = try context.fetch(fetchRequest)

            if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
                existingQuote.isFavorite = isFavorite
                try context.save()
            }
        } catch {
            throw SwiftDataError.saveError
        }
    }

    func updateQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()

        do {
            let quoteEntities = try context.fetch(fetchRequest)

            if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
                existingQuote.author = quote.author
                existingQuote.quote = quote.quote
                existingQuote.category = quote.category
                existingQuote.isFavorite = quote.isFavorite
                existingQuote.tags = quote.tags
                existingQuote.quoteDescription = quote.description
                existingQuote.source = quote.source

                try context.save()
            }
        } catch {
            throw SwiftDataError.saveError
        }
    }
    
    // Funktion zum Hochladen eines Bildes in Firebase Storage
    private func uploadImageToFirebaseStorage(storageRef: StorageReference, imageData: Data, metadata: StorageMetadata) async throws -> String {
        try await withUnsafeThrowingContinuation { continuation in
            storageRef.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let downloadURL = url {
                            print("✅ Bild erfolgreich hochgeladen. URL: \(downloadURL)")
                            continuation.resume(returning: downloadURL.absoluteString)
                        } else {
                            continuation.resume(throwing: NSError(domain: "FirebaseStorageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Abrufen der Bild-URL."]))
                        }
                    }
                }
            }
        }
    }
}
