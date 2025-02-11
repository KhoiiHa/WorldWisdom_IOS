//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//


import Foundation
import SwiftData

@MainActor
class SwiftDataSyncManager {
    private var context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // Methode zum Hinzufügen eines Zitats zu SwiftData
    func addQuote(_ quote: Quote) async throws {
        do {
            let newQuote = QuoteEntity(context: context)
            newQuote.id = quote.id
            newQuote.text = quote.quote
            newQuote.author = quote.author
            // Weitere Eigenschaften setzen, falls nötig...

            try context.save() // Speichern in SwiftData
            try context.refresh(newQuote) // Sicherstellen, dass der Kontext aktualisiert wird
        } catch {
            print("Fehler beim Hinzufügen des Zitats zu SwiftData: \(error.localizedDescription)")
            throw error
        }
    }

    // Methode zum Abrufen der Favoriten-Zitate aus SwiftData
    func fetchFavoriteQuotes() async -> [Quote] {
        do {
            let fetchRequest = QuoteEntity.fetchRequest() // SwiftData spezifisch
            let favoriteQuoteEntities = try context.fetch(fetchRequest)

            // Umwandlung von QuoteEntity in Quote
            let favoriteQuotes = favoriteQuoteEntities.map { quoteEntity in
                Quote(id: quoteEntity.id, quote: quoteEntity.text, author: quoteEntity.author)
            }
            return favoriteQuotes
        } catch {
            print("Fehler beim Abrufen der Favoriten-Zitate aus SwiftData: \(error.localizedDescription)")
            return []
        }
    }

    // Methode zum Entfernen eines Favoriten-Zitats aus SwiftData
    func removeFavoriteQuote(_ quote: Quote) async throws {
        do {
            let fetchRequest = QuoteEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", quote.id)

            if let quoteEntity = try context.fetch(fetchRequest).first {
                context.delete(quoteEntity)
                try context.save() // Änderungen speichern
                try context.refresh(quoteEntity) // Sicherstellen, dass der Kontext aktualisiert wird
            }
        } catch {
            print("Fehler beim Entfernen des Favoriten-Zitats aus SwiftData: \(error.localizedDescription)")
            throw error
        }
    }

    // Methode zum Aktualisieren des Favoriten-Status eines Zitats in SwiftData
    func updateFavoriteStatus(for quote: Quote, isFavorite: Bool) async throws {
        do {
            let fetchRequest = QuoteEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", quote.id)

            if let quoteEntity = try context.fetch(fetchRequest).first {
                // Beispiel: Setze den Favoriten-Status, wenn es ein Attribut gibt
                quoteEntity.isFavorite = isFavorite
                try context.save()
                try context.refresh(quoteEntity) // Sicherstellen, dass der Kontext aktualisiert wird
            }
        } catch {
            print("Fehler beim Aktualisieren des Favoriten-Status: \(error.localizedDescription)")
            throw error
        }
    }

    // Methode zum Löschen eines Zitats aus SwiftData
    func deleteQuote(_ quote: Quote) async throws {
        do {
            let fetchRequest = QuoteEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", quote.id)

            if let quoteEntity = try context.fetch(fetchRequest).first {
                context.delete(quoteEntity)
                try context.save() // Änderungen speichern
                try context.refresh(quoteEntity) // Sicherstellen, dass der Kontext aktualisiert wird
            }
        } catch {
            print("Fehler beim Löschen des Zitats aus SwiftData: \(error.localizedDescription)")
            throw error
        }
    }

    // Methode zum Hinzufügen eines Favoriten-Zitats zu SwiftData
    func addFavoriteQuote(_ quote: Quote) async throws {
        // Hier wird die Methode `addQuote` verwendet, um das Zitat hinzuzufügen
        try await addQuote(quote)
        // Eventuell später spezifische Logik für Favoriten hinzufügen
    }
}
