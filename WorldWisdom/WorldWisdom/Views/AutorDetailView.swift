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
    let quote: Quote

    init(quote: Quote, quoteViewModel: QuoteViewModel) {
        self.quote = quote
        self._isFavorite = State(initialValue: quote.isFavorite)
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
    }

    // MARK: - Autor Bild
    private var authorImage: some View {
        Group {
            if let imageURLString = quote.authorImageURL,
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
}
