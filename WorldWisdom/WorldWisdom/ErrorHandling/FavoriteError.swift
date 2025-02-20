//
//  FavoriteError.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 06.02.25.
//

enum FavoriteError: String, Error, Identifiable {
    case userNotAuthenticated = "Benutzer ist nicht authentifiziert"
    case favoriteAlreadyExists = "Das Zitat ist bereits in den Favoriten"
    case unableToUpdateFavorite = "Fehler beim Aktualisieren der Favoriten"
    case unknownError = "Unbekannter Fehler"
    case networkError = "Netzwerkfehler"
    case firebaseError = "Fehler bei Firebase"
    case decodingError = "Fehler beim Decodieren des Zitats"
    
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
        case .networkError:
            return "Es gab ein Problem mit der Netzwerkverbindung."
        case .firebaseError:
            return "Es gab ein Problem mit Firebase."
        case .decodingError:
            return "Es gab ein Problem beim Verarbeiten des Zitats."
        }
    }
}
