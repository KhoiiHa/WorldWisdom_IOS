//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import Foundation
import SwiftData
import FirebaseFirestore

/// Verwalten von SwiftData-Operationen inkl. Synchronisation mit Firestore.
/// Bietet Methoden zum Hinzufügen, Aktualisieren, Löschen und Synchronisieren von Zitaten.

// MARK: - SwiftDataSyncManager
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

    // MARK: - QuoteEntityActor
    // Actor, der den Zugriff auf QuoteEntity kapselt
    actor QuoteEntityActor {
        private let quoteEntity: QuoteEntity
        
        // Initializer für den Actor
        init(quoteEntity: QuoteEntity) {
            self.quoteEntity = quoteEntity
        }
        
        // Methoden zum sicheren Zugriff auf die Daten
        func getTags() -> [String] {
            return quoteEntity.tags
        }
        
        func getAuthorImageURL() -> String {
            return quoteEntity.authorImageURLs.first ?? ""
        }
    }

    // MARK: - Zitat hinzufügen oder aktualisieren
    // Fügt ein Zitat hinzu oder aktualisiert es in Firestore & SwiftData
    func addOrUpdateQuote(_ quoteEntity: QuoteEntity) {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let existingQuotes = try? context.fetch(fetchRequest)

        if let existingQuote = existingQuotes?.first(where: { $0.id == quoteEntity.id }) {
            // Verwende den Actor, um auf die Felder zuzugreifen
            let actor = QuoteEntityActor(quoteEntity: existingQuote)
            Task {
                let tags = await actor.getTags()

                existingQuote.author = quoteEntity.author
                existingQuote.quoteText = quoteEntity.quoteText
                existingQuote.category = quoteEntity.category
                existingQuote.isFavorite = quoteEntity.isFavorite
                existingQuote.quoteDescription = quoteEntity.quoteDescription
                existingQuote.source = quoteEntity.source
                existingQuote.authorImageURLs = quoteEntity.authorImageURLs
                existingQuote.authorImageData = quoteEntity.authorImageData
                existingQuote.tags = tags

                try? context.save()
            }
        } else {
            // Neues Zitat einfügen
            context.insert(quoteEntity)
            try? context.save()
        }
    }

    // MARK: - Neues Zitat lokal speichern
    // Fügt ein neues Zitat in SwiftData hinzu (ohne Firestore)
    func addQuote(_ quote: Quote) async throws {
        let newQuote = QuoteEntity(
            id: quote.id,
            author: quote.author,
            quoteText: quote.quote,
            category: quote.category,
            tags: quote.tags,
            isFavorite: quote.isFavorite,
            quoteDescription: quote.description,
            source: quote.source,
            authorImageURLs: quote.authorImageURLs ?? [],
            authorImageData: nil
        )
        context.insert(newQuote)
        do {
            try context.save()
        } catch {
            throw SwiftDataError.saveError
        }
    }

    // MARK: - Fallback-Zitate speichern
    // Speichert eine Liste von Fallback-Zitaten in SwiftData
    func storeFallbackQuotes(_ quotes: [Quote]) async throws {
        for quote in quotes {
            try await addQuote(quote)
        }
    }

    // MARK: - Zitate abrufen
    // Asynchrone Methode zum Abrufen der Zitate
    func fetchQuotesAsync(request: FetchDescriptor<QuoteEntity>) async throws -> [QuoteEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let result = try context.fetch(request)
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Favoriten abrufen
    // Lädt alle Favoriten aus SwiftData
    func fetchFavoriteQuotes() async throws -> [Quote] {
        let fetchRequest = FetchDescriptor<QuoteEntity>()

        do {
            let quoteEntities = try await fetchQuotesAsync(request: fetchRequest)

            return try await withThrowingTaskGroup(of: Quote.self) { group in
                for quoteEntity in quoteEntities.filter({ $0.isFavorite }) {
                    // Verwende den Actor für sicheren Zugriff
                    let actor = QuoteEntityActor(quoteEntity: quoteEntity)
                    group.addTask {
                        // Zugriff auf die Felder mit await
                        let tags = await actor.getTags()
                        let authorImageURL = await actor.getAuthorImageURL()
                        return Quote(
                            id: quoteEntity.id,
                            author: quoteEntity.author,
                            quote: quoteEntity.quoteText,
                            category: quoteEntity.category,
                            tags: tags,
                            isFavorite: quoteEntity.isFavorite,
                            description: quoteEntity.quoteDescription,
                            source: quoteEntity.source,
                            authorImageURLs: [authorImageURL]
                        )
                    }
                }
                var localQuotes: [Quote] = []
                for try await quote in group {
                    localQuotes.append(quote)
                }
                return localQuotes
            }
        } catch {
            throw SwiftDataError.fetchError
        }
    }

    // MARK: - Zitat löschen
    // Löscht ein Zitat aus SwiftData & Firestore
    func deleteQuote(_ quote: Quote) async throws {
        let firestore = Firestore.firestore()
        let fetchRequest = FetchDescriptor<QuoteEntity>()

        do {
            let quoteEntities = try await fetchQuotesAsync(request: fetchRequest)

            if let existingQuote = quoteEntities.first(where: { $0.id == quote.id }) {
                context.delete(existingQuote)
                try context.save()
            } else {
                throw SwiftDataError.quoteNotFound
            }

            // Lösche das Zitat aus Firestore
            try await firestore.collection("quotes").document(quote.id).delete()
        } catch {
            throw SwiftDataError.deleteError
        }
    }

    // MARK: - Favorit entfernen
    // Löscht ein Zitat aus den Favoriten in SwiftData
    func removeFavoriteQuote(_ quote: Quote) async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        
        let quoteEntities = try await fetchQuotesAsync(request: fetchRequest)
        
        if let quoteEntity = quoteEntities.first(where: { $0.id == quote.id }) {
            // Entferne das Zitat aus den Favoriten
            context.delete(quoteEntity)
            try context.save()
            print("✅ Zitat erfolgreich aus den Favoriten entfernt.")
        } else {
            throw SwiftDataError.quoteNotFound
        }
    }

    // MARK: - Firestore-Synchronisation
    // Synchronisiert die Zitate aus Firestore mit SwiftData
    func syncQuotesFromFirestore() async {
        do {
            let firestoreQuotes = try await fetchQuotesFromFirestore()

            for quoteEntity in firestoreQuotes {
                let actor = QuoteEntityActor(quoteEntity: quoteEntity)

                // Sicher auf die Felder zugreifen
                let tags = await actor.getTags()
                let authorImageURL = await actor.getAuthorImageURL() // Hier holen wir das Bild-URL

                let fetchRequest = FetchDescriptor<QuoteEntity>()
                let existingQuotes = try context.fetch(fetchRequest)

                if let existingQuote = existingQuotes.first(where: { $0.id == quoteEntity.id }) {
                    // Falls das Zitat existiert, aktualisiere es
                    existingQuote.author = quoteEntity.author
                    existingQuote.quoteText = quoteEntity.quoteText
                    existingQuote.category = quoteEntity.category
                    existingQuote.tags = tags
                    existingQuote.isFavorite = quoteEntity.isFavorite
                    existingQuote.quoteDescription = quoteEntity.quoteDescription
                    existingQuote.source = quoteEntity.source
                    existingQuote.authorImageURLs = quoteEntity.authorImageURLs
                    existingQuote.authorImageData = quoteEntity.authorImageData

                    // Speichern des authorImageURL in die Entity
                    existingQuote.authorImageURLs = [authorImageURL]  // Speichere das Bild-URL in die Entity
                } else {
                    // Falls es das Zitat noch nicht gibt, füge es hinzu
                    context.insert(quoteEntity)
                }

                // Optional: Wenn du das Bild später verwenden möchtest (z.B. als Bilddaten speichern)
                if !quoteEntity.authorImageURLs.isEmpty, let firstImageURL = quoteEntity.authorImageURLs.first, let url = URL(string: firstImageURL) {
                    do {
                        let imageData = try await downloadImageData(from: url)
                        quoteEntity.authorImageData = imageData // Speichere die Bilddaten, falls gewünscht
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

    // MARK: - Bilddaten laden
    // Hilfsfunktion: Lade Bilddaten asynchron herunter
    private func downloadImageData(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    // MARK: - Zitate aus Firestore laden
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
                    let author = data["author"] as? String,
                    let quote = data["quote"] as? String
                else {
                    print("❌ Übersprungen: author oder quote fehlt in \(data)")
                    print("⚠️ Ungültige Kerndaten (author/quote) im Dokument: \(data)")
                    continue
                }

                let id = document.documentID
                let category = data["category"] as? String ?? "Unbekannt"
                let isFavorite = data["isFavorite"] as? Bool ?? false
                let tags = data["tags"] as? [String] ?? []
                let description = data["description"] as? String ?? ""
                let source = data["source"] as? String ?? ""

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
                    authorImageURLs: data["authorImageURLs"] as? [String] ?? []
                ))

                // Füge das QuoteEntity der Liste hinzu
                print("📥 Eingefügtes Zitat von \(author)")
                quoteEntities.append(quoteEntity)
            }
            
            return quoteEntities

        } catch {
            throw SwiftDataError.fetchError
        }
    }
    
    // MARK: - Favoritenstatus aktualisieren
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

    // MARK: - Alle Favoriten entfernen
    // Löscht alle Favoriten-Zitate aus SwiftData
    func removeAllFavoriteQuotes() async throws {
        let fetchRequest = FetchDescriptor<QuoteEntity>()
        let quoteEntities = try await fetchQuotesAsync(request: fetchRequest)

        for quoteEntity in quoteEntities where quoteEntity.isFavorite {
            context.delete(quoteEntity)
        }

        try context.save()
        print("✅ Alle Favoriten-Zitate wurden aus SwiftData gelöscht.")
    }
}
