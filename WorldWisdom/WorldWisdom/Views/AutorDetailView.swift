//
//  AutorDetailView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct AutorDetailView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel // ViewModel für das Zitat
    let quote: Quote // Nutzt die Quote-Struktur
    
    @State private var isFavorite: Bool // Favoritenstatus innerhalb der View

    init(quote: Quote, quoteViewModel: QuoteViewModel) {
        self.quote = quote
        self._isFavorite = State(initialValue: quote.isFavorite) // Initialisieren mit dem Wert aus der Quote-Struktur
        self.quoteViewModel = quoteViewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Autorname
                Text(quote.author)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                // Kategorie oder Tags anzeigen
                Text("Kategorie: \(quote.category)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Zitat
                Text("\"\(quote.quote)\"")
                    .font(.title2)
                    .italic() // Kursivschrift für das Zitat
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                // Tags (falls vorhanden)
                if !quote.tags.isEmpty {
                    Text("Tags: \(quote.tags.joined(separator: ", "))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Favoriten Button
                Button(action: toggleFavoriteStatus) {
                    HStack {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .gray)
                        Text(isFavorite ? "Favorit" : "Zu Favoriten hinzufügen")
                            .font(.headline)
                            .foregroundColor(isFavorite ? .red : .blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.top)
                
                // Link zur Quelle
                if let url = URL(string: quote.source), UIApplication.shared.canOpenURL(url) {
                    Link("Mehr über \(quote.author)", destination: url)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("Ungültiger Link zur Quelle.")
                        .foregroundColor(.red)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Autor Details")
        .onAppear {
            // Optional: Bei der Anzeige weitere Funktionen aufrufen, z.B. Favoritenstatus überprüfen
        }
    }
    
    // Funktion zum Umschalten des Favoritenstatus
    private func toggleFavoriteStatus() {
        isFavorite.toggle() // Favoritenstatus toggeln
        
        // Hier kann eine Funktion im ViewModel aufgerufen werden, um den Favoritenstatus zu speichern
        quoteViewModel.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
    }
}

#Preview {
    AutorDetailView(
        quote: Quote(
            id: "1",
            author: "Albert Einstein",
            quote: "Imagination is more important than knowledge.",
            category: "Inspiration",
            tags: ["Knowledge", "Imagination"],
            isFavorite: false,
            source: "https://en.wikipedia.org/wiki/Albert_Einstein"
        ),
        quoteViewModel: QuoteViewModel() // ViewModel hier einfügen
    )
}
