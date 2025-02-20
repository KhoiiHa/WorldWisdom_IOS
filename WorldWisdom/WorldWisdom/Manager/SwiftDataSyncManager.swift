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
import FirebaseStorage
import UIKit

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

    
    // Fügt ein Zitat hinzu oder aktualisiert es in Firestore & SwiftData
    func addOrUpdateQuote(_ quoteEntity: QuoteEntity) {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let existingQuotes = try? context.fetch(fetchRequest)

        if let existingQuote = existingQuotes?.first(where: { $0.id == quoteEntity.id }) {
            // Update des bestehenden Zitats
            existingQuote.author = quoteEntity.author
            existingQuote.quote = quoteEntity.quote
            existingQuote.category = quoteEntity.category
            existingQuote.isFavorite = quoteEntity.isFavorite
            existingQuote.quoteDescription = quoteEntity.quoteDescription
            existingQuote.source = quoteEntity.source
            existingQuote.authorImageURLs = quoteEntity.authorImageURLs
            existingQuote.authorImageData = quoteEntity.authorImageData
        } else {
            // Neues Zitat einfügen
            context.insert(quoteEntity)
        }

        try? context.save()
    }
    
    
    // Fügt ein neues Zitat in SwiftData hinzu (ohne Firestore)
    func addQuote(_ quote: Quote) async throws {
        let newQuote = QuoteEntity(
            id: quote.id,
            author: quote.author,
            quote: quote.quote,
            category: quote.category,
            tags: quote.tags,
            isFavorite: quote.isFavorite,
            quoteDescription: quote.description,
            source: quote.source,
            authorImageURLs: quote.authorImageURLs,
            authorImageData: nil
        )
        context.insert(newQuote)

        do {
            try context.save()
        } catch {
            throw SwiftDataError.saveError
        }
    }

    // Entfernt ein Zitat aus den Favoriten in SwiftData
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

    // Lädt alle Favoriten aus SwiftData
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
                    authorImageURLs: entity.authorImageURLs ?? []
                )
            }
        } catch {
            throw SwiftDataError.fetchError
        }
    }
    
    
    // Löscht ein Zitat aus SwiftData & Firestore
    func deleteQuote(_ quote: Quote) async throws {
        let firestore = Firestore.firestore()
        let fetchRequest = FetchDescriptor<QuoteEntity>()

        do {
            let quoteEntities = try context.fetch(fetchRequest)

            if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
                context.delete(existingQuote)
                try context.save()
            }

            // Lösche das Zitat aus Firestore
            try await firestore.collection("quotes").document(quote.id).delete()
        } catch {
            throw SwiftDataError.deleteError
        }
    }

    // Synchronisiert die Zitate aus Firestore mit SwiftData
    func syncQuotesFromFirestore() async {
        do {
            let firestoreQuotes = try await fetchQuotesFromFirestore()

            for quoteEntity in firestoreQuotes {
                // Hier prüfst du, ob das Zitat in SwiftData bereits existiert
                let fetchRequest = FetchDescriptor<QuoteEntity>()
                let existingQuotes = try context.fetch(fetchRequest)

                if let existingQuote = existingQuotes.first(where: { $0.id == quoteEntity.id }) {
                    // Falls das Zitat existiert, aktualisiere es
                    existingQuote.author = quoteEntity.author
                    existingQuote.quote = quoteEntity.quote
                    existingQuote.category = quoteEntity.category
                    existingQuote.tags = quoteEntity.tags
                    existingQuote.isFavorite = quoteEntity.isFavorite
                    existingQuote.quoteDescription = quoteEntity.quoteDescription
                    existingQuote.source = quoteEntity.source
                    existingQuote.authorImageURLs = quoteEntity.authorImageURLs
                    existingQuote.authorImageData = quoteEntity.authorImageData
                } else {
                    // Falls es das Zitat noch nicht gibt, füge es hinzu
                    context.insert(quoteEntity)
                }

                // Hier kannst du die Cloudinary-Logik beibehalten
                if let authorImageURLs = quoteEntity.authorImageURLs, let firstImageURL = authorImageURLs.first, let url = URL(string: firstImageURL) {
                    do {
                        let imageData = try await downloadImageData(from: url)
                        quoteEntity.authorImageData = imageData
                    } catch {
                        print("❌ Fehler beim Laden des Bildes: \(error.localizedDescription)")
                    }
                }
            }

            try context.save()
            print("✅ Firestore-Zitate erfolgreich synchronisiert.")
        } catch {
            print("❌ Fehler beim Synchronisieren: \(error.localizedDescription)")
        }
    }

    // Hilfsfunktion: Lade Bilddaten asynchron herunter
    private func downloadImageData(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    // Hole alle Zitate aus Firestore
    private func fetchQuotesFromFirestore() async throws -> [QuoteEntity] {
        let firestore = Firestore.firestore()
        let quotesCollection = firestore.collection("quotes")
        
        var quoteEntities: [QuoteEntity] = []

        do {
            let snapshot = try await quotesCollection.getDocuments()

            // Durchlaufen jedes Dokuments
            for document in snapshot.documents {
                let data = document.data()

                // Entpacken der Felder und Absichern der optionalen Werte
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
                
                    quoteEntities.append(
                        QuoteEntity(id: "", author: "", quote: "", category: "", tags: [], isFavorite: false, quoteDescription: "", source: "", authorImageURLs: nil, authorImageData: nil)
                    )
                    continue // Überspringe ungültige Daten und fahre mit dem nächsten Zitat fort
                }

                // Erstelle ein gültiges QuoteEntity
                let quoteEntity = QuoteEntity.fromFirebaseModel(quote: Quote(
                    id: id,
                    author: author,
                    quote: quote,
                    category: category,
                    tags: tags,
                    isFavorite: isFavorite,
                    description: description,
                    source: source,
                    authorImageURLs: data["authorImageURL"] as? [String] 
                ))

                // Füge das QuoteEntity der Liste hinzu
                quoteEntities.append(quoteEntity)
            }
            
            return quoteEntities

        } catch {
            throw SwiftDataError.fetchError
        }
    }
    
    func updateFavoriteStatus(for quote: Quote, to isFavorite: Bool) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quotes = try context.fetch(fetchRequest)
        
        // Finde das Zitat anhand der ID
        guard let quoteEntity = quotes.first(where: { $0.id == quote.id }) else {
            throw SwiftDataError.quoteNotFound
        }

        // Aktualisiere den Favoritenstatus
        quoteEntity.isFavorite = isFavorite

        // Speichern der Änderungen in der Datenbank
        try context.save()

        print("✅ Favoritenstatus für Zitat \(quote.id) erfolgreich aktualisiert.")
    }

}
