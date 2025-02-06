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

    var id: String { rawValue }
}
