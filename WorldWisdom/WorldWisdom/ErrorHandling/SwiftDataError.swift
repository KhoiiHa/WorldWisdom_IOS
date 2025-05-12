//
//  SwiftDataError.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 12.02.25.
//

import Foundation

/// Fehler, die im Zusammenhang mit SwiftData-Vorgängen wie Speichern, Abrufen oder Synchronisieren auftreten können.

// MARK: - SwiftDataError

// Enum für Fehler im Zusammenhang mit SwiftData
enum SwiftDataError: LocalizedError {
    case saveError
    case fetchError
    case deleteError
    case quoteNotFound
    case syncError
    case unknownError        

    // MARK: - LocalizedError Conformance

    /// Benutzerfreundliche Beschreibung für jeden Fehlerfall
    var errorDescription: String? {
        switch self {
        case .saveError:
            return "Fehler beim Speichern der Daten."
        case .fetchError:
            return "Fehler beim Abrufen der Daten."
        case .deleteError:
            return "Fehler beim Löschen der Daten."
        case .quoteNotFound:
            return "Das angeforderte Zitat wurde nicht gefunden."
        case .syncError:
            return "Fehler bei der Synchronisation der Daten."
        case .unknownError:
            return "Unbekannter Fehler."
        }
    }

    /// Vorschläge zur Behebung des jeweiligen Fehlers
    var recoverySuggestion: String? {
        switch self {
        case .saveError:
            return "Versuche es später erneut."
        case .fetchError:
            return "Überprüfe, ob die Daten vorhanden sind und versuche es erneut."
        case .deleteError:
            return "Überprüfe die Verbindung und versuche es erneut."
        case .quoteNotFound:
            return "Stelle sicher, dass das Zitat existiert und versuche es erneut."
        case .syncError:
            return "Überprüfe deine Netzwerkverbindung und versuche es später erneut."
        case .unknownError:
            return "Unbekannter Fehler aufgetreten. Versuche es später erneut."
        }
    }
}
