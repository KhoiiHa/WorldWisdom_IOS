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
    private var context: ModelContext {
        return container.mainContext
    }

    init() {
        // Initialisierung des ModelContainers mit der QuoteEntity
        self.container = try! ModelContainer(for: QuoteEntity.self, configurations: ModelConfiguration())
    }

    func addQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
            // Zitat existiert bereits, aktualisieren
            existingQuote.author = quote.author
            existingQuote.quote = quote.quote
            existingQuote.category = quote.category
            existingQuote.isFavorite = quote.isFavorite
            existingQuote.tags = quote.tags.joined(separator: ", ")
            existingQuote.quoteDescription = quote.description
            existingQuote.source = quote.source
        } else {
            // Zitat existiert nicht, neu hinzufügen
            let newQuote = QuoteEntity(
                id: quote.id,
                author: quote.author,
                quote: quote.quote,
                category: quote.category,
                tags: quote.tags.joined(separator: ", "),
                isFavorite: quote.isFavorite,
                quoteDescription: quote.description,
                source: quote.source
            )
            context.insert(newQuote)
        }

        try context.save() // Änderungen speichern
    }

    // Markiert ein Zitat als Favorit
    func addFavoriteQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
            // Zitat existiert bereits, aktualisieren
            existingQuote.isFavorite = true
        } else {
            // Zitat existiert nicht, neu hinzufügen
            // Tags als String speichern (durch Komma getrennt)
            let tagsString = quote.tags.joined(separator: ", ")

            let newQuote = QuoteEntity(
                id: quote.id,
                author: quote.author,
                quote: quote.quote,
                category: quote.category,
                tags: tagsString,  // Tags als String speichern
                isFavorite: true,
                quoteDescription: quote.description,
                source: quote.source
            )
            context.insert(newQuote)
        }

        try context.save() // Änderungen speichern
    }
    
    
    // Entfernt ein Zitat aus den Favoriten
    func removeFavoriteQuote(_ quote: Quote) async throws {
        try await updateFavoriteStatus(for: quote, to: false)
    }

    // Löscht ein Zitat aus SwiftData
    func deleteQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        if let quoteEntity = quoteEntities.first(where: { $0.id == quote.id }) {
            context.delete(quoteEntity)
            try context.save()
        }
    }

    // Fügt ein Zitat hinzu oder aktualisiert es (gemeinsam für Add und Update)
    func addOrUpdateQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
            // Zitat existiert bereits, aktualisieren
            existingQuote.author = quote.author
            existingQuote.quote = quote.quote
            existingQuote.category = quote.category
            existingQuote.isFavorite = quote.isFavorite
            // Tags als String speichern (durch Komma getrennt)
            existingQuote.tags = quote.tags.joined(separator: ", ")
            existingQuote.quoteDescription = quote.description
            existingQuote.source = quote.source
        } else {
            // Zitat existiert nicht, neu hinzufügen
            // Tags als String speichern (durch Komma getrennt)
            let tagsString = quote.tags.joined(separator: ", ")

            let newQuote = QuoteEntity(
                id: quote.id,
                author: quote.author,
                quote: quote.quote,
                category: quote.category,
                tags: tagsString,  // Tags als String speichern
                isFavorite: quote.isFavorite,
                quoteDescription: quote.description,
                source: quote.source
            )
            context.insert(newQuote)
        }

        try context.save() // Änderungen speichern
    }

    // Holt alle Favoriten aus SwiftData
    func fetchFavoriteQuotes() async throws -> [Quote] {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let favoriteQuoteEntities = try context.fetch(fetchRequest)

        return favoriteQuoteEntities.map { quoteEntity in
            // Konvertiere tags von String zurück in Array
            let tagsArray = quoteEntity.tags.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            
            return Quote(
                id: quoteEntity.id,
                author: quoteEntity.author,
                quote: quoteEntity.quote,
                category: quoteEntity.category,
                tags: tagsArray,  // Tags als Array
                isFavorite: quoteEntity.isFavorite,
                description: quoteEntity.quoteDescription,
                source: quoteEntity.source
            )
        }
    }

    // Synchronisiert Zitate von Firestore zu SwiftData
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

    // Holt Zitate aus Firestore
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
                let tags = data["tags"] as? [String], // Erwartet ein Array von Strings
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
                tags: tags,  // Tags direkt als Array
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
    
    
    func updateQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try context.fetch(fetchRequest)

        if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
            // Aktualisiere das Zitat mit den neuen Werten
            existingQuote.author = quote.author
            existingQuote.quote = quote.quote
            existingQuote.category = quote.category
            existingQuote.isFavorite = quote.isFavorite
            // Tags von Array in String umwandeln (durch Komma getrennt)
            existingQuote.tags = quote.tags.joined(separator: ", ")
            existingQuote.quoteDescription = quote.description
            existingQuote.source = quote.source

            // Speichere die Änderungen in SwiftData
            try context.save()
        }
    }
}
