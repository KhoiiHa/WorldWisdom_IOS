//
//  CloudinaryError.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 18.02.25.
//

import Foundation

enum CloudinaryError: LocalizedError {
    case uploadFailed
    case invalidImageUrl
    case firestoreSaveFailed
    case noImageUrlsFound
    case authorNotFound
    case noImageFound

    var errorDescription: String? {
        switch self {
        case .uploadFailed:
            return "Fehler beim Hochladen des Bildes auf Cloudinary."
        case .invalidImageUrl:
            return "Keine gültige URL für das Bild erhalten."
        case .firestoreSaveFailed:
            return "Fehler beim Speichern der Bild-URL in Firestore."
        case .noImageUrlsFound:
            return "Es wurden keine Bild-URLs für den Autor gefunden."
        case .authorNotFound:
            return "Autor nicht gefunden."
        case .noImageFound:
            return "Es wurde kein Bild für den Autor gefunden."
        }
    }
}
