//
//  CloudinaryManager.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 18.02.25.
//

import Cloudinary
import FirebaseFirestore
import SwiftData

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

    // Bild in Cloudinary hochladen und URL in Firestore speichern
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

        
        let document = try await authorRef.getDocument()

        guard document.exists else {
            throw CloudinaryError.authorNotFound
        }

        // Mache den Firestore Update-Aufruf im Hintergrund
        try await Task.detached(priority: .background) {
            try await authorRef.updateData([
                "authorImageUrls": FieldValue.arrayUnion([imageUrl])
            ])
        }.value
        
        print("✅ Bild-URL erfolgreich in Firestore gespeichert")
    }
    
    
    // Bild für einen Autor abrufen (gibt eine Liste der URLs zurück)
    // modelContext: ModelContext muss von außen übergeben werden
    func fetchImagesForAuthor(authorId: String, modelContext: ModelContext) async throws -> [String] {
        let authorRef = db.collection("authors").document(authorId)
        let document = try await authorRef.getDocument()

        guard document.exists else {
            print("❌ Kein Autor mit ID \(authorId) gefunden")
            throw CloudinaryError.authorNotFound
        }

        if let imageUrls = document.get("authorImageUrls") as? [String], !imageUrls.isEmpty {
            // Save first image to SwiftData
            if let firstUrlString = imageUrls.first, let url = URL(string: firstUrlString), let data = try? Data(contentsOf: url) {
                saveFirstImageToSwiftData(authorId: authorId, imageData: data, modelContext: modelContext)
            }
            return imageUrls
        } else {
            print("⚠️ Keine Bilder für \(authorId) gefunden. Fallback auf Platzhalter.")
            return ["https://res.cloudinary.com/dpaehynl2/image/upload/v1739866635/cld-sample-4.jpg"]
        }
    }

    // Abrufen von allen Autorenbildern (falls benötigt)
    func fetchAllAuthorImages(modelContext: ModelContext) async {
        do {
            let authorIds = try await getAllAuthorIds()
            for authorId in authorIds {
                do {
                    let images = try await fetchImagesForAuthor(authorId: authorId, modelContext: modelContext)
                    imageUrls.append(contentsOf: images)
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

// MARK: - SwiftData helper
private func saveFirstImageToSwiftData(authorId: String, imageData: Data, modelContext: ModelContext) {
    let descriptor = FetchDescriptor<QuoteEntity>(predicate: #Predicate { $0.author == authorId })
    if let quoteEntity = try? modelContext.fetch(descriptor).first {
        quoteEntity.authorImageData = imageData
        try? modelContext.save()
    }
}
