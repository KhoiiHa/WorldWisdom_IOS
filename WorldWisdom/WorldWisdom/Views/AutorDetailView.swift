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
    @State private var currentImageIndex: Int = 0
    let quote: Quote
    
    init(quote: Quote, quoteViewModel: QuoteViewModel) {
        self.quote = quote
        self._isFavorite = State(initialValue: quote.isFavorite)
        self.quoteViewModel = quoteViewModel
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
                    Text(quote.author)
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
                }
                .padding(.horizontal)
                .padding(.top, 30)
            }
            
            // Favoriten-Button
            favoriteButton
        }
        .navigationTitle(quote.author)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.5), value: currentImageIndex) // Animation für Bildwechsel
    }
    
    private var authorImage: some View {
        VStack {
            if let imageUrls = quote.authorImageURLs, !imageUrls.isEmpty {
                AsyncImage(url: URL(string: imageUrls[currentImageIndex])) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 180, height: 180)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: 5)
                            .transition(.opacity) // Animation für Bildwechsel
                    case .failure:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .foregroundColor(.gray.opacity(0.5))
                    @unknown default:
                        EmptyView()
                    }
                }
                
                HStack {
                    Button(action: showPreviousImage) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .scaleEffect(currentImageIndex == 0 ? 1.0 : 1.2) // Animation für Pfeil-Button
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: currentImageIndex)
                    }
                    .disabled(currentImageIndex == 0)
                    
                    Spacer()
                    
                    Button(action: showNextImage) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .scaleEffect(currentImageIndex == imageUrls.count - 1 ? 1.0 : 1.2) // Animation für Pfeil-Button
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
    
    private var favoriteButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title)
                        .foregroundColor(isFavorite ? Color.red : Color.white)
                        .padding(18)
                        .background(
                            Circle()
                                .fill(isFavorite ? Color.red.opacity(0.1) : Color.white.opacity(0.3))
                        )
                        .overlay(
                            Circle() // Dünner Rand für den Button
                                .stroke(isFavorite ? Color.red : Color.white, lineWidth: 2)
                        )
                        .shadow(radius: 2) // Weniger auffällige Schattierung
                        .scaleEffect(isFavorite ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isFavorite) // Sanfter Übergang
                }
                .padding(.trailing, 30)
                .padding(.bottom, 25)
            }
        }
    }
    
    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.white)
                    .font(.caption)
                
                Text("„\(quote.quote)“")
                    .font(.body)
                    .italic()
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                    .lineLimit(4)
            }

            if !quote.tags.isEmpty {
                Text("Themen: \(quote.tags.joined(separator: ", "))")
                    .font(.footnote)
                    .foregroundColor(.yellow) // Gelb für einen starken Kontrast zu den anderen Elementen
                    .bold()
            }

            Text("- \(quote.author)")
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
            Text("Über \(quote.author)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white) // Weißer Text für besseren Kontrast

            Text(quote.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.85)) // Leicht transparenter Text für bessere Lesbarkeit
                .lineLimit(nil) // Keine Begrenzung für die Zeilenanzahl (Text wird komplett angezeigt)
                .fixedSize(horizontal: false, vertical: true) // Text wächst vertikal, wenn nötig
                
            if let sourceURL = URL(string: quote.source) {
                Link("Mehr über \(quote.author)", destination: sourceURL)
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
    
    private func toggleFavorite() {
        Task {
            await quoteViewModel.updateFavoriteStatus(for: quote, isFavorite: !isFavorite)
            withAnimation {
                isFavorite.toggle()
            }
        }
    }
    
    private func showPreviousImage() {
        guard currentImageIndex > 0 else { return }
        withAnimation {
            currentImageIndex -= 1
        }
    }

    private func showNextImage() {
        guard let imageUrls = quote.authorImageURLs, currentImageIndex < imageUrls.count - 1 else { return }
        withAnimation {
            currentImageIndex += 1
        }
    }
}
