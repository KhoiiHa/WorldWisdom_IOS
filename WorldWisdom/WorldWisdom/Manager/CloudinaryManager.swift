//
//  CloudinaryManager.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 18.02.25.
//

import Cloudinary
import FirebaseFirestore

@MainActor
class CloudinaryManager: ObservableObject {
    static let shared = CloudinaryManager()
    
    private let cloudinary: CLDCloudinary
    private let db = Firestore.firestore()
    
    @Published var imageUrls: [String] = []
    
    private init() {
        let config = CLDConfiguration(cloudName: "dpaehynl2", secure: true)
        self.cloudinary = CLDCloudinary(configuration: config)
    }

    // 📌 Bild in Cloudinary hochladen und URL in Firestore speichern
    func uploadImage(imageData: Data, authorId: String) async throws -> String {
        let uploader = cloudinary.createUploader()
        
        let result: String = try await withCheckedThrowingContinuation { continuation in
            uploader.upload(data: imageData, uploadPreset: "WorldWisdom", completionHandler:  { (uploadResult: CLDUploadResult?, error: Error?) in
                if error != nil {
                    continuation.resume(throwing: CloudinaryError.uploadFailed)
                    return
                }
                
                guard let imageUrl = uploadResult?.secureUrl else {
                    continuation.resume(throwing: CloudinaryError.invalidImageUrl)
                    return
                }
                continuation.resume(returning: imageUrl)
            })
        }

        do {
            try await saveImageUrlToFirestore(authorId: authorId, imageUrl: result)
        } catch {
            throw CloudinaryError.firestoreSaveFailed
        }

        return result
    }
    
    private func saveImageUrlToFirestore(authorId: String, imageUrl: String) async throws {
        let authorRef = db.collection("authors").document(authorId)

        // Hole das Dokument im Hintergrund, um sicherzustellen, dass wir es nicht auf dem Haupt-Thread tun
        let document = try await authorRef.getDocument()

        guard document.exists else {
            throw CloudinaryError.authorNotFound
        }

        // Mache den Firestore Update-Aufruf im Hintergrund (verhindert Datenrennen)
        try await Task.detached(priority: .background) {
            try await authorRef.updateData([
                "authorImageUrls": FieldValue.arrayUnion([imageUrl])
            ])
        }.value
        
        print("✅ Bild-URL erfolgreich in Firestore gespeichert")
    }
    
    
    // 📌 Bild für einen Autor abrufen (gibt eine Liste der URLs zurück)
    func fetchImagesForAuthor(authorId: String) async throws -> [String] {
        let authorRef = db.collection("authors").document(authorId)
        let document = try await authorRef.getDocument()

        guard document.exists else {
            print("❌ Kein Autor mit ID \(authorId) gefunden")
            throw CloudinaryError.authorNotFound
        }

        if let imageUrls = document.get("authorImageUrls") as? [String], !imageUrls.isEmpty {
            return imageUrls
        } else {
            print("⚠️ Keine Bilder für \(authorId) gefunden. Fallback auf Platzhalter.")
            return ["https://res.cloudinary.com/dpaehynl2/image/upload/v1739866635/cld-sample-4.jpg"]
        }
    }

    // 📌 Abrufen von allen Autorenbildern (falls benötigt)
    func fetchAllAuthorImages() async {
        do {
            let authorIds = try await getAllAuthorIds() // Hol dir alle Autoren-IDs
            for authorId in authorIds {
                do {
                    let images = try await fetchImagesForAuthor(authorId: authorId)
                    imageUrls.append(contentsOf: images) // Direkt in die @Published Liste einfügen
                } catch {
                    print("Fehler beim Abrufen der Bilder für Autor \(authorId): \(error)")
                }
            }
        } catch {
            print("Fehler beim Abrufen der Autoren-IDs: \(error)")
        }
    }

    private func getAllAuthorIds() async throws -> [String] {
        let snapshot = try await db.collection("authors").getDocuments()
        return snapshot.documents.compactMap { $0.documentID }
    }
}
