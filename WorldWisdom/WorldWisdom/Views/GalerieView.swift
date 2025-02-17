//
//  GalerieView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 14.02.25.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct GalerieScreen: View {
    let authorId: String
    @State private var imageUrls: [String] = []
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isUploadingImage = false

    var body: some View {
        VStack {
            // 📌 Bild-Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(imageUrls, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { phase in
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

            // 📌 Button zum Hochladen eines neuen Bildes
            Button(action: { isImagePickerPresented = true }) {
                Text("Neues Bild hochladen")
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
        }
        .onAppear {
            fetchImages() // Bilder beim Laden der View abrufen
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage, isPresented: $isImagePickerPresented)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let newImage = newImage {
                uploadImageToFirebase(newImage)
            }
        }
    }

    // 📌 Bilder aus Firebase Storage abrufen
    private func fetchImages() {
        FirebaseManager.shared.fetchImages(for: authorId) { result in
            switch result {
            case .success(let urls):
                imageUrls = urls // Erfolg: Setze die URLs
            case .failure(let error):
                print("Fehler beim Abrufen der Bilder: \(error.localizedDescription)") // Fehlerbehandlung
            }
        }
    }

    // 📌 Bild in Firebase hochladen (mit async/await)
    private func uploadImageToFirebase(_ image: UIImage) {
        isUploadingImage = true
        Task {
            do {
                // Bild hochladen und URL abrufen
                let imageUrl = try await FirebaseManager.shared.uploadAuthorImage(image: image, authorId: authorId)
                
                // URL zur Liste der Bild-URLs hinzufügen
                imageUrls.append(imageUrl)
            } catch {
                print("Fehler beim Hochladen des Bildes: \(error.localizedDescription)")
            }
            // Nach Abschluss des Uploads das Upload-Flag zurücksetzen
            isUploadingImage = false
        }
    }
}
