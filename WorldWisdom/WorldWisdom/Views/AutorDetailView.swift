//
//  AutorDetailView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct AutorDetailView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel
    @State private var isFavorite: Bool
    @State private var authorImageURL: String?
    @State private var errorMessage: ErrorMessage? // Fehler-Message als Identifiable
    let quote: Quote

    init(quote: Quote, quoteViewModel: QuoteViewModel) {
        self.quote = quote
        self._isFavorite = State(initialValue: quote.isFavorite)
        self._authorImageURL = State(initialValue: quote.authorImageURL) // Initialisierung mit Bild-URL
        self.quoteViewModel = quoteViewModel
    }

    var body: some View {
        ZStack {
            // Hintergrund-Farbverlauf
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // 📌 Autor-Bild
                    authorImage

                    Text(quote.author)
                        .font(.title.bold())

                    // 📌 Galerie-Button
                    NavigationLink(destination: GalerieScreen(authorId: quote.id)) {
                        Text("📸 Galerie ansehen")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                    }
                    .padding(.horizontal)

                    // 📌 Zitat-Card
                    quoteCard

                    // 📌 Autor-Info-Card
                    authorInfoCard
                }
                .padding(.horizontal)
                .padding(.top, 30)
            }

            // 📌 Favoriten-Button
            favoriteButton
        }
        .navigationTitle(quote.author)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadAuthorImage() // Bild laden wenn die View erscheint
        }
        .alert(item: $errorMessage) { errorMessage in
            Alert(title: Text("Fehler"), message: Text(errorMessage.message), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Autor Bild
    private var authorImage: some View {
        Group {
            if let imageURLString = authorImageURL,
               let imageURL = URL(string: imageURLString), !imageURLString.isEmpty {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Ladeindikator
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 100, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray.opacity(0.5))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Standardbild, wenn keine URL vorhanden oder ungültig ist
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
    }

    // MARK: - Favoriten-Button
    private var favoriteButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title)
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(20)
                        .background(Circle().fill(isFavorite ? Color.white : Color.red))
                        .shadow(radius: 10)
                        .scaleEffect(isFavorite ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isFavorite)
                }
                .padding(.trailing, 30)
                .padding(.bottom, 30)
            }
        }
    }

    // MARK: - Zitat-Card
    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("„\(quote.quote)“")
                .font(.title3)
                .italic()

            if !quote.tags.isEmpty {
                Text("Themen: \(quote.tags.joined(separator: ", "))")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 5))
    }

    // MARK: - Autor-Info-Card
    private var authorInfoCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Über \(quote.author)")
                .font(.title2)
                .fontWeight(.bold)

            Text(quote.description)
                .font(.body)
                .foregroundColor(.primary)

            if let sourceURL = URL(string: quote.source) {
                Link("Mehr über \(quote.author)", destination: sourceURL)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                    .shadow(radius: 5)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 5))
    }

    // MARK: - Favoriten-Button Aktion
    private func toggleFavorite() {
        Task {
            await quoteViewModel.updateFavoriteStatus(for: quote, isFavorite: !isFavorite)
            withAnimation {
                isFavorite.toggle()
            }
        }
    }

    // MARK: - Autor-Bild anzeigen (mit CloudinaryManager)
    private func loadAuthorImage() {
        Task {
            do {
                // Bild-URLs mit async/await laden (diesmal als Array von URLs)
                let imageURLs = try await CloudinaryManager.shared.fetchImagesForAuthor(authorId: quote.id)
                
                // Debug: Gib die Bild-URLs aus
                print("Bild-URLs für den Autor:", imageURLs)
                
                // Falls ein Bild vorhanden ist, nehmen wir das erste Bild aus dem Array
                if let firstImageURL = imageURLs.first, !firstImageURL.isEmpty {
                    authorImageURL = firstImageURL // Bild-URL aktualisieren
                } else {
                    // Keine gültige Bild-URL gefunden
                    showAlert(for: "Kein Bild gefunden für diesen Autor." as! Error)
                }
            } catch {
                // Fehler im UI anzeigen
                showAlert(for: "Fehler beim Laden des Bildes: \(error.localizedDescription)" as! Error)
            }
        }
    }

    private func showAlert(for error: Error) {
        let errorMessage: ErrorMessage
        if let cloudinaryError = error as? CloudinaryError {
            errorMessage = ErrorMessage(message: cloudinaryError.errorDescription ?? "Unbekannter Fehler")
        } else {
            errorMessage = ErrorMessage(message: error.localizedDescription)
        }
        self.errorMessage = errorMessage
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID() // UUID stellt sicher, dass jedes Fehlerobjekt eindeutig ist
    let message: String
}
