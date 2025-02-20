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
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
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
                        .font(.title.bold())
                    
                    // Zitat-Card
                    quoteCard
                    
                    // Autor-Info-Card
                    authorInfoCard
                }
                .padding(.horizontal)
                .padding(.top, 30)
            }
            
            // Favoriten-Button
            favoriteButton
        }
        .navigationTitle(quote.author)
        .navigationBarTitleDisplayMode(.inline)
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
                    }
                    .disabled(currentImageIndex == 0)
                    
                    Spacer()
                    
                    Button(action: showNextImage) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
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
    
    private func toggleFavorite() {
        Task {
            await quoteViewModel.updateFavoriteStatus(for: quote, isFavorite: !isFavorite)
            withAnimation {
                isFavorite.toggle()
            }
        }
    }
    
    private func showPreviousImage() {
        if currentImageIndex > 0 {
            withAnimation {
                currentImageIndex -= 1
            }
        }
    }
    
    private func showNextImage() {
        if let imageUrls = quote.authorImageURLs, currentImageIndex < imageUrls.count - 1 {
            withAnimation {
                currentImageIndex += 1
            }
        }
    }
}
