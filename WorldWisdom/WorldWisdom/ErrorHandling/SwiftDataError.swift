//
//  SwiftDataError.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 12.02.25.
//

import Foundation

// Enum für Fehler im Zusammenhang mit SwiftData
enum SwiftDataError: LocalizedError {
    case saveError           // Fehler beim Speichern von Daten
    case fetchError          // Fehler beim Abrufen von Daten
    case deleteError         // Fehler beim Löschen von Daten
    case unknownError        // Unbekannter Fehler

    // Fehlermeldungen basierend auf dem Fehler-Typ
    var errorDescription: String? {
        switch self {
        case .saveError:
            return "Fehler beim Speichern der Daten."
        case .fetchError:
            return "Fehler beim Abrufen der Daten."
        case .deleteError:
            return "Fehler beim Löschen der Daten."
        case .unknownError:
            return "Unbekannter Fehler."
        }
    }

    // Vorschläge zur Fehlerbehebung
    var recoverySuggestion: String? {
        switch self {
        case .saveError:
            return "Versuche es später erneut."
        case .fetchError:
            return "Überprüfe, ob die Daten vorhanden sind und versuche es erneut."
        case .deleteError:
            return "Überprüfe die Verbindung und versuche es erneut."
        case .unknownError:
            return "Unbekannter Fehler aufgetreten. Versuche es später erneut."
        }
    }
}
