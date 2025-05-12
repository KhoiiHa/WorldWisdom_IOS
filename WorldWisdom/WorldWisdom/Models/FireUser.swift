/// Datenmodell für Benutzerinformationen aus Firebase Authentication

// MARK: - FireUser

struct FireUser {
    var id: String                          // Lokale ID (z. B. aus Firestore-Dokument)
    var email: String?                      // E-Mail-Adresse (optional)
    var name: String?                       // Benutzername (optional)
    var uid: String                         // Firebase Authentication UID
    var favoriteQuoteIds: [String]          // Liste von favorisierten Zitat-IDs
    var authorId: String?                   // Zuordnung zu einem Autorprofil (optional)
}
