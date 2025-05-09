//
//  AutorDetailView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI
import SDWebImageSwiftUI
import _SwiftData_SwiftUI
import Foundation

struct AutorDetailView: View {
    @State private var currentImageIndex: Int = 0
    let authorName: String
    let selectedQuoteText: String? // optional für gezieltes Anzeigen
    @Query var quotes: [QuoteEntity]
    @State private var isFavorite: Bool = false
    @State private var selectedQuote: QuoteEntity? = nil
    
    var filteredQuotes: [QuoteEntity] {
        quotes.filter { $0.author == authorName }
    }
    var quote: QuoteEntity? {
        if let selectedText = selectedQuoteText {
            return filteredQuotes.first(where: { $0.quoteText == selectedText })
        }
        return filteredQuotes.first
    }
    
    init(authorName: String, selectedQuoteText: String? = nil) {
        self.authorName = authorName
        self.selectedQuoteText = selectedQuoteText
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.black.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Autor-Bild mit Pfeilen
                    authorImage
                    
                    // Nur Autor-Name
                    Text(quote?.author ?? authorName)
                        .font(.system(size: 34, weight: .bold, design: .serif)) // Serifenschrift für eleganteren Look
                        .foregroundColor(.white)
                        .shadow(radius: 2) // Dezente Schattierung für mehr Tiefe
                        .transition(.opacity) // Animation für den Autor-Namen
                    
                    // Zitat-Card
                    quoteCard
                        .transition(.move(edge: .bottom).combined(with: .opacity)) // Animation für die Zitat-Karte
                    
                    // Autor-Info-Card
                    authorInfoCard
                        .transition(.move(edge: .trailing).combined(with: .opacity)) // Animation für die Autor-Info-Karte
                    
                    if filteredQuotes.count > 1 {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Weitere Zitate von \(authorName)")
                                .font(.title3)
                                .foregroundColor(.white)

                            ForEach(filteredQuotes.dropFirst(), id: \.self) { additionalQuote in
                                Button(action: {
                                    selectedQuote = additionalQuote
                                }) {
                                    Text("„\(additionalQuote.quoteText)“")
                                        .font(.body)
                                        .italic()
                                        .foregroundColor(.white.opacity(0.9))
                                        .padding(.vertical, 6)
                                        .padding(.horizontal)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 30)
            }
        }
        .navigationTitle(quote?.author ?? authorName)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.5), value: currentImageIndex) // Animation für Bildwechsel
        .navigationDestination(item: $selectedQuote) { quote in
            AutorDetailView(authorName: quote.author, selectedQuoteText: quote.quoteText)
        }
    }
    
    private var authorImage: some View {
        VStack {
            if let imageData = quote?.authorImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
                    .transition(.opacity)
            } else if let imageUrls = quote?.authorImageURLs, !imageUrls.isEmpty {
                SDWebImageSwiftUI.WebImage(url: URL(string: imageUrls[currentImageIndex]))
                    .resizable()
                    .indicator(SDWebImageSwiftUI.Indicator.activity)
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)

                let imageUrls = quote?.authorImageURLs ?? []
                HStack {
                    Button(action: showPreviousImage) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .scaleEffect(currentImageIndex == 0 ? 1.0 : 1.2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: currentImageIndex)
                    }
                    .disabled(currentImageIndex == 0)

                    Spacer()

                    Button(action: showNextImage) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .scaleEffect(currentImageIndex == imageUrls.count - 1 ? 1.0 : 1.2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: currentImageIndex)
                    }
                    .disabled(currentImageIndex == imageUrls.count - 1)
                }
                .padding(.horizontal, 50)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
    }
    
    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                if let quote = quote {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            isFavorite.toggle()
                        }
                        Task {
                            await FavoriteManager.shared.updateFavoriteStatus(for: quote.toQuote(), isFavorite: isFavorite)
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .white)
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                            .scaleEffect(isFavorite ? 1.2 : 1.0)
                    }
                    
                }
            }
            
            Text("„\(quote?.quoteText ?? "")“")
                .font(.title3)
                .fontWeight(.semibold)
                .italic()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(6)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)

            if let tags = quote?.tags, !tags.isEmpty {
                Text("Themen: \(tags.joined(separator: ", "))")
                    .font(.footnote)
                    .foregroundColor(.yellow) // Gelb für einen starken Kontrast zu den anderen Elementen
                    .bold()
            }

            Text("- \(quote?.author ?? authorName)")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Color.black // Fester schwarzer Hintergrund
                .opacity(0.85)
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
    }
    
    private var authorInfoCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Über \(quote?.author ?? authorName)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white) // Weißer Text für besseren Kontrast

            Text(quote?.quoteDescription ?? "")
                .font(.body)
                .foregroundColor(.white.opacity(0.85)) // Leicht transparenter Text für bessere Lesbarkeit
                .lineLimit(nil) // Keine Begrenzung für die Zeilenanzahl (Text wird komplett angezeigt)
                .fixedSize(horizontal: false, vertical: true) // Text wächst vertikal, wenn nötig
                
            if let sourceString = quote?.source, let sourceURL = URL(string: sourceString) {
                Link("Mehr über \(quote?.author ?? authorName)", destination: sourceURL)
                    .foregroundColor(.white) // Weißer Text für guten Kontrast
                    .padding()
                    .frame(maxWidth: 250)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.7)) // Sanftes Grau statt Blau
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1) // Weißer Rand für besseres Herausstechen
                    )
                    .shadow(radius: 5) // Dezente Schattierung für 3D-Effekt
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.black // Dunkler Hintergrund für stärkeren Kontrast
                .opacity(0.85)
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
    }
    
    private func showPreviousImage() {
        guard currentImageIndex > 0 else { return }
        withAnimation {
            currentImageIndex -= 1
        }
    }

    private func showNextImage() {
        guard let imageUrls = quote?.authorImageURLs, currentImageIndex < imageUrls.count - 1 else { return }
        withAnimation {
            currentImageIndex += 1
        }
    }
}

private extension QuoteEntity {
    func toQuote() -> Quote {
        return Quote(
            id: self.id,
            author: self.author,
            quote: self.quoteText,
            category: self.category,
            tags: self.tags,
            isFavorite: self.isFavorite,
            description: self.quoteDescription,
            source: self.source,
            authorImageURLs: self.authorImageURLs,
            authorImageData: self.authorImageData
        )
    }
}

