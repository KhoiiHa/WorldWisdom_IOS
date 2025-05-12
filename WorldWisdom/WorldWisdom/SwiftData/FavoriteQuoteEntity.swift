//
//  Untitled.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 11.02.25.
//

import SwiftData
import Foundation
import FirebaseFirestore

/// SwiftData-Entity zur lokalen Speicherung von favorisierten Zitaten inkl. Offline-Unterstützung.
/// Nutzt JSON-kodierte Strings für Arrays (tags & authorImageURLs) zur Kompatibilität mit SwiftData.

// MARK: - FavoriteQuoteEntity
@Model
class FavoriteQuoteEntity {
    @Attribute(.unique) var id: String
    var quoteId: String
    var userId: String
    var quoteText: String
    var author: String
    var category: String?
    var tagsJSON: String?
    var authorImageURLsJSON: String?
    var quoteDescription: String?
    var source: String?

    // MARK: - Dekodierte Eigenschaften (tags & authorImageURLs)
    var tags: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data((tagsJSON ?? "").utf8))) ?? []
        }
        set {
            tagsJSON = (try? JSONEncoder().encode(newValue)).flatMap { String(data: $0, encoding: .utf8) }
        }
    }

    var authorImageURLs: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data((authorImageURLsJSON ?? "").utf8))) ?? []
        }
        set {
            authorImageURLsJSON = (try? JSONEncoder().encode(newValue)).flatMap { String(data: $0, encoding: .utf8) }
        }
    }

    // MARK: - Initialisierer
    init(id: String = UUID().uuidString, quoteId: String, userId: String, quoteText: String, author: String, category: String? = nil, tagsJSON: String? = nil, authorImageURLsJSON: String? = nil, description: String? = nil, source: String? = nil) {
        self.id = id
        self.quoteId = quoteId
        self.userId = userId
        self.quoteText = quoteText
        self.author = author
        self.category = category
        self.tagsJSON = tagsJSON
        self.authorImageURLsJSON = authorImageURLsJSON
        self.quoteDescription = description
        self.source = source
    }
}
