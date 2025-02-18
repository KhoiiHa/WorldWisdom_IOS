//
//  GalerieView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 14.02.25.
//

import SwiftUI

struct GalerieScreen: View {
    let authorId: String
    @State private var imageUrls: [String] = []
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isUploadingImage = false
    @State private var uploadError: CloudinaryError?

    // Platzhalter-URL von Cloudinary
    private let placeholderImageURL = "https://res.cloudinary.com/dpaehynl2/image/upload/v1739866635/cld-sample-4.jpg"

    var body: some View {
        VStack {
            // 📌 Bild-Grid
            ScrollView {
                if imageUrls.isEmpty {
                    Text("Keine Bilder verfügbar")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(imageUrls, id: \.self) { url in
                            // Verwende die Platzhalter-URL, wenn die URL leer oder ungültig ist
                            let imageUrl = url.isEmpty ? placeholderImageURL : url
                            
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(height: 100)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                case .failure:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                        .foregroundColor(.gray.opacity(0.5))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }

            // 📌 Button zum Hochladen eines neuen Bildes
            Button(action: { isImagePickerPresented = true }) {
                Text("📸 Neues Bild hochladen")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
            }
            .padding()
            .disabled(isUploadingImage)

            // Zeige Ladeanzeige während des Uploads
            if isUploadingImage {
                ProgressView("Bild wird hochgeladen...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }

            // Fehlermeldung anzeigen
            if let uploadError {
                Text("❌ Fehler: \(uploadError.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage, isPresented: $isImagePickerPresented)
        }
        .onAppear {
            // Bild-URLs vom Autor beim Laden der View abrufen
            Task {
                await fetchImagesForAuthor()
            }
        }
        .onChange(of: selectedImage) { _, newImage in
            if let newImage = newImage {
                Task {
                    await uploadImageToCloudinary(newImage)
                }
            }
        }
    }

    // 📌 Bild-URLs des Autors abrufen
    private func fetchImagesForAuthor() async {
        do {
            // Hier holen wir die Bild-URLs aus Firestore (es wird ein Array erwartet)
            let fetchedImageUrls = try await CloudinaryManager.shared.fetchImagesForAuthor(authorId: authorId)
            imageUrls = fetchedImageUrls  // Direktes Zuweisen des Arrays
        } catch {
            print("Fehler beim Abrufen der Bild-URLs: \(error)")
            // Falls ein Fehler auftritt, nutzen wir den Platzhalter
            imageUrls = [placeholderImageURL]  // Hier stellst du sicher, dass es ein Array bleibt
        }
    }

    // 📌 Bild in Cloudinary hochladen
    private func uploadImageToCloudinary(_ image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        isUploadingImage = true
        uploadError = nil

        do {
            let imageUrl = try await CloudinaryManager.shared.uploadImage(imageData: imageData, authorId: authorId)
            // Erfolgreiches Hochladen
            imageUrls.append(imageUrl)  // Bild zur Liste hinzufügen
        } catch {
            // Fehlerbehandlung
            if let cloudinaryError = error as? CloudinaryError {
                uploadError = cloudinaryError
            } else {
                uploadError = .uploadFailed // Fallback für unerwartete Fehler
            }
        }

        isUploadingImage = false
    }
}
