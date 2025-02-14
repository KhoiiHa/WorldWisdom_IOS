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
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .opacity(0.1)

            ScrollView {
                VStack(spacing: 20) {
                    // 📌 Kopfbereich mit Autor-Bild
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 10)

                    Text(quote.author)
                        .font(.title.bold())

                    // 📌 Zitat-Card
                    quoteCard

                    // 📌 Autor-Info-Card
                    authorInfoCard
                }
                .padding(.horizontal)
                .padding(.top, 30)
            }

            // 📌 Favoriten-Button
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
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 30)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isFavorite)
                }
            }
        }
        .navigationTitle(quote.author)
        .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    AutorDetailView(
        quote: Quote(
            id: "1",
            author: "Albert Einstein",
            quote: "Imagination is more important than knowledge.",
            category: "Inspiration",
            tags: ["Wissen", "Philosophie"],
            isFavorite: false,
            description: "Albert Einstein war ein theoretischer Physiker, bekannt für die Relativitätstheorie.",
            source: "https://de.wikipedia.org/wiki/Albert_Einstein"
        ),
        quoteViewModel: QuoteViewModel()
    )
}
