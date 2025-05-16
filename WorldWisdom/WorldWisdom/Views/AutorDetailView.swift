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
            // MARK: Hintergrund Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("background"), Color("cardBackground")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: Autor-Bild mit Pfeilen
                    authorImage
                    
                    // MARK: Autor-Name
                    Text(quote?.author ?? authorName)
                        .font(.system(size: 34, weight: .bold, design: .serif)) // Serifenschrift für eleganteren Look
                        .foregroundColor(Color("primaryText").opacity(0.95))
                        .shadow(color: Color("primaryText").opacity(0.3), radius: 1)
                        .shadow(radius: 2) // Dezente Schattierung für mehr Tiefe
                        .transition(.opacity) // Animation für den Autor-Namen
                    
                    // MARK: Zitat-Card
                    quoteCard
                        .transition(.move(edge: .bottom).combined(with: .opacity)) // Animation für die Zitat-Karte
                    
                    // MARK: Autor-Info-Card
                    authorInfoCard
                        .transition(.move(edge: .trailing).combined(with: .opacity)) // Animation für die Autor-Info-Karte
                    
                    // MARK: Weitere Zitate
                    if filteredQuotes.count > 1 {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Weitere Zitate von \(authorName)")
                                .font(.title3)
                                .foregroundColor(Color("primaryText"))

                            ForEach(filteredQuotes.dropFirst(), id: \.self) { additionalQuote in
                                Button(action: {
                                    selectedQuote = additionalQuote
                                }) {
                                    Text("„\(additionalQuote.quoteText)“")
                                        .font(.body)
                                        .italic()
                                        .foregroundColor(Color("primaryText"))
                                        .padding(.vertical, 6)
                                        .padding(.horizontal)
                                        .background(Color("cardBackground"))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .shadow(color: Color("buttonColor").opacity(0.13), radius: 4, x: 0, y: 2)
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
    
    // MARK: Autor-Bild mit Navigation
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
                            .accentColor(Color("mainBlue"))
                            .scaleEffect(currentImageIndex == 0 ? 1.0 : 1.2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: currentImageIndex)
                    }
                    .disabled(currentImageIndex == 0)

                    Spacer()

                    Button(action: showNextImage) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.largeTitle)
                            .accentColor(Color("mainBlue"))
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
                    .foregroundColor(Color("secondaryText").opacity(0.5))
            }
        }
    }
    
    // MARK: Zitat-Card mit Favoriten Button
    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                if quote != nil {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            isFavorite.toggle()
                        }
                        Task {
                            if let quote = quote {
                                await FavoriteManager.shared.updateFavoriteStatus(for: quote.toQuote(), isFavorite: isFavorite)
                            }
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : Color("primaryText"))
                            .padding(8)
                            .background(Color("primaryText").opacity(0.1))
                            .clipShape(Circle())
                            .scaleEffect(isFavorite ? 1.2 : 1.0)
                    }
                    
                }
            }
            
            Text("„\(quote?.quoteText ?? "")“")
                .font(.title3)
                .fontWeight(.semibold)
                .italic()
                .foregroundColor(Color("primaryText"))
                .multilineTextAlignment(.center)
                .lineLimit(6)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)

            if let tags = quote?.tags, !tags.isEmpty {
                Text("Themen: \(tags.joined(separator: ", "))")
                    .font(.footnote)
                    .foregroundColor(Color("mainBlue")) // Gelb für einen starken Kontrast zu den anderen Elementen
                    .bold()
            }

            Text("- \(quote?.author ?? authorName)")
                .font(.caption)
                .foregroundColor(Color("primaryText"))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Color("cardBackground")
        )
        .cornerRadius(15)
        .shadow(color: Color("buttonColor").opacity(0.13), radius: 10, x: 0, y: 5)
    }
    
    // MARK: Autor-Info-Card mit Beschreibung und Link
    private var authorInfoCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Über \(quote?.author ?? authorName)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("primaryText")) // Weißer Text für besseren Kontrast

            Text(quote?.quoteDescription ?? "")
                .font(.body)
                .foregroundColor(Color("primaryText").opacity(0.85)) // Leicht transparenter Text für bessere Lesbarkeit
                .lineLimit(nil) // Keine Begrenzung für die Zeilenanzahl (Text wird komplett angezeigt)
                .fixedSize(horizontal: false, vertical: true) // Text wächst vertikal, wenn nötig
                
            if let sourceString = quote?.source, let sourceURL = URL(string: sourceString) {
                Link("Mehr über \(quote?.author ?? authorName)", destination: sourceURL)
                    .font(.subheadline)
                    .foregroundColor(Color("primaryText")) // Weißer Text für guten Kontrast
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: 200)
                    .multilineTextAlignment(.center)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("mainBlue").opacity(0.8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("primaryText"), lineWidth: 1) // Weißer Rand für besseres Herausstechen
                    )
                    .shadow(radius: 8) // Dezente Schattierung für 3D-Effekt
            }
            
            if let facts = AuthorFunFacts.facts[quote?.author ?? authorName], !facts.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Wusstest du schon?")
                        .font(.headline)
                        .foregroundColor(Color("mainBlue"))
                    
                    Text(facts.randomElement() ?? "")
                        .font(.subheadline)
                        .foregroundColor(Color("primaryText").opacity(0.9))
                        .italic()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color("cardBackground")
        )
        .cornerRadius(15)
        .shadow(color: Color("buttonColor").opacity(0.13), radius: 8, x: 0, y: 4)
    }
    
    // MARK: Bildwechsel Funktionen
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
