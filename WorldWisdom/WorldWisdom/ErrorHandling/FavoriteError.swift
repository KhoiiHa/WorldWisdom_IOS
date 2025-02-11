//
//  FavoriteError.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 06.02.25.
//

import Foundation

enum FavoriteError: String, Error, Identifiable {
    case userNotAuthenticated = "Benutzer ist nicht authentifiziert"
    case favoriteAlreadyExists = "Das Zitat ist bereits in den Favoriten"
    case unableToUpdateFavorite = "Fehler beim Aktualisieren der Favoriten"
    case unknownError = "Unbekannter Fehler"
    
    var id: String { rawValue }
    
    // Fehlerbeschreibung für eine einfache Anzeige
    var errorMessage: String {
        switch self {
        case .userNotAuthenticated:
            return "Bitte melden Sie sich an, um Favoriten zu verwalten."
        case .favoriteAlreadyExists:
            return "Das Zitat ist bereits in Ihrer Favoritenliste."
        case .unableToUpdateFavorite:
            return "Es gab ein Problem beim Aktualisieren des Favoriten."
        case .unknownError:
            return "Es ist ein unbekannter Fehler aufgetreten. Bitte versuchen Sie es später erneut."
        }
    }
}
