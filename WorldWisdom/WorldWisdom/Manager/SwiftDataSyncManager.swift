//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import Foundation
import SwiftData
import FirebaseFirestore

@MainActor
class SwiftDataSyncManager {

    private var container: ModelContainer

    internal var context: ModelContext {
        return container.mainContext
    }

    init() {
        self.container = try! ModelContainer(for: QuoteEntity.self, configurations: ModelConfiguration())
    }

    // Fügt ein Zitat hinzu oder aktualisiert es
    func addOrUpdateQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
            existingQuote.author = quote.author
            existingQuote.quote = quote.quote
            existingQuote.category = quote.category
            existingQuote.isFavorite = quote.isFavorite
            existingQuote.tags = quote.tags.joined(separator: ", ")
            existingQuote.quoteDescription = quote.description
            existingQuote.source = quote.source
        } else {
            let tagsString = quote.tags.joined(separator: ", ")

            let newQuote = QuoteEntity(
                id: quote.id,
                author: quote.author,
                quote: quote.quote,
                category: quote.category,
                tags: tagsString,
                isFavorite: quote.isFavorite,
                quoteDescription: quote.description,
                source: quote.source
            )
            context.insert(newQuote)
        }

        try context.save() // Änderungen speichern
    }

    // Fügt nur ein neues Zitat hinzu, ohne nach vorhandenen zu suchen
    func addQuote(_ quote: Quote) async throws {
        let tagsString = quote.tags.joined(separator: ", ")

        let newQuote = QuoteEntity(
            id: quote.id,
            author: quote.author,
            quote: quote.quote,
            category: quote.category,
            tags: tagsString,
            isFavorite: quote.isFavorite,
            quoteDescription: quote.description,
            source: quote.source
        )
        context.insert(newQuote)

        try context.save() // Änderungen speichern
    }

    // Entfernt ein Zitat aus den Favoriten
    func removeFavoriteQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
            existingQuote.isFavorite = false
            try context.save()
        }
    }

    // Lädt die Favoriten aus SwiftData
    func fetchFavoriteQuotes() async throws -> [Quote] {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        return quoteEntities.filter { $0.isFavorite }.map { entity in
            Quote(
                id: entity.id,
                author: entity.author,
                quote: entity.quote,
                category: entity.category,
                tags: entity.tags.split(separator: ", ").map { String($0) },
                isFavorite: entity.isFavorite,
                description: entity.quoteDescription,
                source: entity.source
            )
        }
    }

    // Löscht ein Zitat
    func deleteQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
            context.delete(existingQuote)
            try context.save()
        }
    }

    // Synchronisiert die Zitate aus Firestore mit SwiftData
    func syncQuotesFromFirestore() async {
        do {
            let firestoreQuotes = try await fetchQuotesFromFirestore()

            for quote in firestoreQuotes {
                try await addOrUpdateQuote(quote)
            }

            print("✅ Firestore-Zitate erfolgreich mit SwiftData synchronisiert.")
        } catch {
            print("❌ Fehler beim Synchronisieren von Firestore: \(error)")
        }
    }

    private func fetchQuotesFromFirestore() async throws -> [Quote] {
        let firestore = Firestore.firestore()
        let quotesCollection = firestore.collection("quotes")

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
                return nil
            }

            return Quote(
                id: id,
                author: author,
                quote: quote,
                category: category,
                tags: tags,
                isFavorite: isFavorite,
                description: description,
                source: source
            )
        }
    }

    // Aktualisiert den Favoritenstatus eines Zitats
    func updateFavoriteStatus(for quote: Quote, to isFavorite: Bool) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
            existingQuote.isFavorite = isFavorite
            try context.save()
        }
    }

    // Aktualisiert ein Zitat
    func updateQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
            existingQuote.author = quote.author
            existingQuote.quote = quote.quote
            existingQuote.category = quote.category
            existingQuote.isFavorite = quote.isFavorite
            existingQuote.tags = quote.tags.joined(separator: ", ")
            existingQuote.quoteDescription = quote.description
            existingQuote.source = quote.source

            try context.save()
        }
    }
    
    
}
