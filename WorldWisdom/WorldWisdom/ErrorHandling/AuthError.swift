//
//  AuthError.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 16.01.25.
//

import SwiftUI
import FirebaseAuth

// Enum für Authentifizierungsfehler
enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case unknownError

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
        }
    }
}
