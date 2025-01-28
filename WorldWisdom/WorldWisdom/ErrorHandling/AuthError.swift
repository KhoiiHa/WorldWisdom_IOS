//
//  AuthError.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 16.01.25.
//

import Foundation
import FirebaseAuth

// Enum für Authentifizierungsfehler
enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case unknownError
    case customError(String) // Möglichkeit, benutzerdefinierte Fehlernachrichten hinzuzufügen

    // Fehlermeldung für jedes Error-Case
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Die angegebene E-Mail-Adresse ist ungültig."
        case .weakPassword:
            return "Das Passwort ist zu schwach. Bitte wählen Sie ein stärkeres Passwort."
        case .emailAlreadyInUse:
            return "Diese E-Mail-Adresse wird bereits verwendet."
        case .unknownError:
            return "Es ist ein unbekannter Fehler aufgetreten."
        case .customError(let message):
            return message // Gibt eine benutzerdefinierte Fehlermeldung zurück
        }
    }

    // Fehlerbehandlung für benutzerdefinierte Fehlercodes oder andere Fehler
    static func handleCustomError(_ message: String) -> String {
        return AuthError.customError(message).errorDescription ?? "Unbekannter Fehler"
    }
    
    // Statische Methode zur Fehlerbehandlung mit Firebase-Fehlercode
    static func handleFirebaseError(_ error: NSError) -> String {
        // Firebase-spezifische Fehlerbehandlung
        switch error.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return AuthError.invalidEmail.errorDescription ?? "Unbekannter Fehler"
        case AuthErrorCode.weakPassword.rawValue:
            return AuthError.weakPassword.errorDescription ?? "Unbekannter Fehler"
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return AuthError.emailAlreadyInUse.errorDescription ?? "Unbekannter Fehler"
        default:
            return AuthError.unknownError.errorDescription ?? "Unbekannter Fehler"
        }
    }
}
