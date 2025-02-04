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
    @State private var searchQuery: String = ""
    
    init(quote: Quote, quoteViewModel: QuoteViewModel) {
        self.quote = quote
        self._isFavorite = State(initialValue: quote.isFavorite ?? false)
        self.quoteViewModel = quoteViewModel
    }
    
    var body: some View {
        ZStack {
            // Hintergrund
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .opacity(0.1)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Kopfbereich
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 10)
                    
                    Text(quote.author)
                        .font(.title.bold())
                    
                    Text("„\(quote.quote)“")
                        .font(.title3)
                        .italic()
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10))
                    
                    if !quote.tags.isEmpty {
                        Text("Themen: \(quote.tags.joined(separator: ", "))")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    
                    // Suchleiste
                    TextField("Suche nach Zitaten...", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Autoren-Info-Link
                    if let url = URL(string: quote.source) {
                        Link("Mehr über \(quote.author)", destination: url)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal)
            }
            
            // Favorite-Button
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
            description: "Albert Einstein was a physicist.",
            source: "https://en.wikipedia.org/wiki/Albert_Einstein"
        ),
        quoteViewModel: QuoteViewModel()
    )
}
