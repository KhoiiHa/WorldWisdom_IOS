//
//  FirebaseError.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 14.02.25.
//

import Foundation

enum FirebaseError: Error, LocalizedError {
    case noAuthenticatedUser
    case unknownError(String)
    case uploadFailed
    case favoriteAlreadyExists
    case favoriteNotFound
    case userNotAuthenticated
    case fetchFailed
    case authorImageUploadFailed
    case imageDownloadFailed
    
    var errorDescription: String? {
        switch self {
        case .noAuthenticatedUser:
            return "Es gibt keinen authentifizierten Benutzer."
        case .unknownError(let message):
            return "Unbekannter Fehler: \(message)"
        case .uploadFailed:
            return "Der Upload ist fehlgeschlagen."
        case .favoriteAlreadyExists:
            return "Das Zitat ist bereits in den Favoriten."
        case .favoriteNotFound:
            return "Favorisiertes Zitat nicht gefunden."
        case .userNotAuthenticated:
            return "Benutzer ist nicht authentifiziert."
        case .fetchFailed:
            return "Abruf der Daten ist fehlgeschlagen."
        case .authorImageUploadFailed:
            return "Fehler beim Hochladen des Autorenbildes."
        case .imageDownloadFailed:
            return "Fehler beim Abrufen des Bildes."
        }
    }
}
