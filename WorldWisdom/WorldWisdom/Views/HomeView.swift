//
//  HomeView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//
import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var quoteViewModel = QuoteViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    welcomeSection
                    dailyQuoteSection
                    recommendedQuotesSection
                    newQuoteButton
                }
                .padding(20)
            }
            .navigationTitle("Home")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .task {
                if quoteViewModel.quotes.isEmpty {
                    await loadQuotes()
                }
                if quoteViewModel.randomQuote == nil {
                    quoteViewModel.getRandomQuote()
                }
            }
        }
    }

    // MARK: - Willkommensnachricht
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Willkommen zurück!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)
                .padding(.bottom, 5)

            if let user = userViewModel.user {
                Text(user.email ?? "Anonym angemeldet. UID: \(user.uid)")
                    .font(.subheadline)
                    .foregroundColor(user.email != nil ? .green : .blue)
                    .opacity(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Zitat des Tages
    private var dailyQuoteSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Zitat des Tages")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)

            if let quote = quoteViewModel.randomQuote {
                NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: quoteViewModel)) {
                    quoteCard(quote)
                }

                Button(action: {
                    Task {
                        let isFavorite = !quote.isFavorite
                        await quoteViewModel.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
                    }
                }) {
                    HStack {
                        Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(quote.isFavorite ? .red : .gray)
                        Text(quote.isFavorite ? "Favorit entfernen" : "Favorisieren")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                ProgressView("Lädt Zitat des Tages...")
                    .padding()
                    .foregroundColor(.secondary)
            }

            // Fehleranzeige
            if let errorMessage = quoteViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
        }
    }

    // MARK: - Empfohlene Zitate
    private var recommendedQuotesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Empfohlene Zitate")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(quoteViewModel.quotes.prefix(5), id: \.id) { quote in
                        NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: quoteViewModel)) {
                            recommendedQuoteCard(quote)
                        }
                    }
                }
                .padding(.horizontal, 20) // Padding für besseren Abstand zum Rand
                .padding(.trailing, 20) // Extra Padding, um den nächsten Card-Teil sichtbar zu machen
            }
        }
    }

    // MARK: - Zitat-Karte (für Zitat des Tages)
    private func quoteCard(_ quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("„\(quote.quote)“")
                .font(.body)
                .italic()
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)

            Text("- \(quote.author)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // MARK: - Breitere Zitat-Karte (für empfohlene Zitate)
    private func recommendedQuoteCard(_ quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("„\(quote.quote)“")
                .font(.body)
                .italic()
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
                .lineLimit(4) // Begrenze den Text auf 4 Zeilen

            Text("- \(quote.author)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 250) // Breitere Karte (250 Punkte)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    // MARK: - Neues Zitat-Button
    private var newQuoteButton: some View {
        Button(action: { Task { quoteViewModel.getRandomQuote() } }) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                Text("Neues Zitat laden")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15)
            .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }

    // Laden der Zitate mit Fehlerbehandlung
    private func loadQuotes() async {
        do {
            try await quoteViewModel.loadAllQuotes()
        } catch {
            print("Fehler beim Laden der Zitate: \(error.localizedDescription)")
            quoteViewModel.errorMessage = "Fehler beim Laden der Zitate: \(error.localizedDescription)"
        }
    }
}

#Preview {
    HomeView(userViewModel: UserViewModel())
}
