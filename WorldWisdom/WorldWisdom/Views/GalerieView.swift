//
//  GalerieView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 14.02.25.
//

import SwiftUI
import SwiftData

struct GalerieScreen: View {
    let authorId: String
    @Environment(\.modelContext) private var modelContext
    @State private var imageUrls: [String] = []
    @State private var filteredImages: [String] = []
    @State private var selectedCategory: String? = nil
    @State private var searchText: String = ""
    @State private var showErrorMessage: Bool = false
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isUploadingImage = false
    @State private var uploadError: CloudinaryError?
    @State private var isLoading = false
    let categories = ["Alle", "Kategorie 1", "Kategorie 2", "Kategorie 3"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                // FilterBar für die Kategorien
                FilterBar(selectedCategory: $selectedCategory, categories: categories)
                
                // Suchleiste
                searchBar

                // Ladeanzeige, wenn Bilder geladen werden
                if isLoading && imageUrls.isEmpty {
                    ProgressView("Bilder werden geladen...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    // Gitteransicht der Bilder
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(filteredImages, id: \.self) { url in
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
                }

                // Button zum Bild hochladen
                Button(action: { isImagePickerPresented = true }) {
                    Text("📸 Neues Bild hochladen")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                }
                .padding()
                .disabled(isUploadingImage)

                // Ladeanzeige für den Bild-Upload
                if isUploadingImage {
                    ProgressView("Bild wird hochgeladen...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }

                // Fehlernachricht beim Laden der Bilder
                if showErrorMessage {
                    Text("❌ Fehler beim Laden der Bilder. Bitte versuchen Sie es später erneut.")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                // Fehlernachricht beim Hochladen des Bildes
                if let uploadError {
                    Text("❌ Fehler: \(uploadError.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .alert(isPresented: $showErrorMessage) {
                Alert(
                    title: Text("Fehler"),
                    message: Text("❌ Fehler beim Laden der Bilder. Bitte versuchen Sie es später erneut."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, isPresented: $isImagePickerPresented)
            }
            .onAppear {
                Task {
                    await fetchImagesForAuthor(modelContext: modelContext) // Bilder laden
                }
            }
            .onChange(of: selectedCategory) { _, _ in
                filterImages()
            }
            .onChange(of: selectedImage) { _, newImage in
                if let newImage {
                    Task {
                        await uploadImageToCloudinary(newImage) // Bild hochladen
                    }
                }
            }
        }
    }

    // Bilder nach Kategorie und Suchtext filtern
    private func filterImages() {
        if let selectedCategory = selectedCategory {
            filteredImages = imageUrls.filter { url in
                url.localizedCaseInsensitiveContains(selectedCategory)
            }
        } else {
            filteredImages = imageUrls
        }
        // Zusätzlich nach Suchtext filtern
        if !searchText.isEmpty {
            filteredImages = filteredImages.filter { url in
                url.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // Suchleiste
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("🔍 Nach Bild suchen...", text: $searchText)
                .foregroundColor(.primary)
                .onChange(of: searchText) { _, _ in
                    filterImages()
                }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    // Bilder für den Autor abrufen
    private func fetchImagesForAuthor(modelContext: ModelContext) async {
        isLoading = true
        do {
            let fetchedImageUrls = try await CloudinaryManager.shared.fetchImagesForAuthor(authorId: authorId, modelContext: modelContext)
            print("🚀 Geladene Bild-URLs: \(fetchedImageUrls)")  // Prüfen, ob URLs korrekt abgerufen werden
            imageUrls = fetchedImageUrls
            filterImages()
        } catch {
            print("Fehler beim Abrufen der Bild-URLs: \(error)")
            showErrorMessage = true
        }
        isLoading = false
    }

    // Bild in Cloudinary hochladen
    private func uploadImageToCloudinary(_ image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        isUploadingImage = true
        uploadError = nil

        do {
            let imageUrl = try await CloudinaryManager.shared.uploadImage(imageData: imageData, authorId: authorId)
            imageUrls.append(imageUrl)
            filterImages()
        } catch {
            if let cloudinaryError = error as? CloudinaryError {
                uploadError = cloudinaryError
            } else {
                uploadError = .uploadFailed
            }
        }

        isUploadingImage = false
    }
}
