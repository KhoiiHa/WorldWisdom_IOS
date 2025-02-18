//
//  CloudinaryManager.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 18.02.25.
//

import Cloudinary
import FirebaseFirestore
import UIKit

class CloudinaryManager {
    static let shared = CloudinaryManager()
    
    private let cloudinary: CLDCloudinary
    private let db = Firestore.firestore()

    private init() {
        let config = CLDConfiguration(cloudName: "dpaehynl2", secure: true)
        self.cloudinary = CLDCloudinary(configuration: config)
    }

    // 📌 Bild in Cloudinary hochladen und URL in Firestore speichern (mit async/await)
    func uploadImage(imageData: Data, authorId: String) async throws -> String {
        let uploader = cloudinary.createUploader()
        
        // Spezifiziere den Rückgabetyp der Result-Closure
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

        // 🔹 Speichere die URL in Firestore
        do {
            try await saveImageUrlToFirestore(authorId: authorId, imageUrl: result)
        } catch {
            throw CloudinaryError.firestoreSaveFailed
        }

        return result
    }
    
    // 📌 Bild-URL in Firestore speichern (mehrere URLs pro Autor) mit async/await
    private func saveImageUrlToFirestore(authorId: String, imageUrl: String) async throws {
        let authorRef = db.collection("authors").document(authorId)

        let document = try await authorRef.getDocument()
        
        guard document.exists else {
            throw CloudinaryError.authorNotFound
        }
        
        // Aktualisiere die Liste der Bild-URLs
        try await authorRef.updateData([
            "authorImageUrls": FieldValue.arrayUnion([imageUrl]) // Füge die neue URL zu einem Array hinzu
        ])
        
        print("✅ Bild-URL erfolgreich in Firestore gespeichert")
    }

    // 📌 Bild für einen Autor abrufen (gibt eine Liste der URLs zurück) mit async/await
    func fetchImagesForAuthor(authorId: String) async throws -> [String] {
        let authorRef = db.collection("authors").document(authorId)
        let document = try await authorRef.getDocument()

        guard let imageUrls = document.get("authorImageUrls") as? [String], !imageUrls.isEmpty else {
            throw CloudinaryError.noImageUrlsFound
        }
        
        return imageUrls
    }
}
