//
//  QuoteError.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 28.01.25.
//

import Foundation

/// Fehler, die beim Abrufen, Parsen oder Anzeigen von Zitaten auftreten können.

// MARK: - QuoteError

// Enum für verschiedene Fehlerarten im Zusammenhang mit Zitaten
enum QuoteError: LocalizedError {
    case networkError(String)  // Fehler beim Netzwerkzugriff
    case parsingError(String)  // Fehler beim Parsen von Daten
    case noQuotesFound         // Keine Zitate gefunden
    case unknownError(String)  // Unbekannter Fehler

    /// Benutzerfreundliche Beschreibung des jeweiligen Fehlers
    // Fehlermeldungen basierend auf dem Fehler-Typ
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Netzwerkfehler: \(message)"
        case .parsingError(let message):
            return "Fehler beim Parsen der Zitate: \(message)"
        case .noQuotesFound:
            return "Es wurden keine Zitate gefunden."
        case .unknownError(let message):
            return "Unbekannter Fehler: \(message)"
        }
    }
    
    /// Wandelt generische Fehler in spezifische QuoteError-Fälle um
    // Hilfsmethode zur Erstellung des Fehler-Enums
    static func handleError(_ error: Error) -> QuoteError {
        // Wenn es ein Netzwerkfehler ist
        if let urlError = error as? URLError {
            return .networkError(urlError.localizedDescription)
        }
        // Wenn es ein Parsing-Fehler ist
        else if error is DecodingError {
            return .parsingError("Fehler beim Decodieren der Daten.")
        }
        // Sonstige Fehler
        else {
            return .unknownError(error.localizedDescription)
        }
    }
    
    /// Vorschläge zur Fehlerbehebung für jede Fehlerart
    // Vorschläge zur Fehlerbehebung
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Bitte überprüfe deine Internetverbindung und versuche es erneut."
        case .parsingError:
            return "Die Daten konnten nicht korrekt verarbeitet werden. Bitte versuche es später erneut."
        case .noQuotesFound:
            return "Es wurden keine Zitate gefunden. Bitte versuche es später erneut."
        case .unknownError:
            return "Unbekannter Fehler aufgetreten. Versuche es später erneut."
        }
    }
}
