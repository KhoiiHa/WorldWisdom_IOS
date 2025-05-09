//
//  HomeView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//
import SwiftUI
import SwiftData
import SDWebImageSwiftUI

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
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.90, green: 0.92, blue: 0.96)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .task {
                if quoteViewModel.quotes.isEmpty {
                    await loadQuotes()
                }
                if quoteViewModel.randomQuote == nil {
                    await quoteViewModel.getRandomQuote()
                }
            }
        }
    }

    // MARK: - Willkommensnachricht
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Willkommen zurück!")
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .foregroundColor(.primary)
                .padding(.bottom, 5)

            // Handle optional email with fallback text
            if let user = userViewModel.user {
                Text(user.email ?? "Nutzer ist Anonym angemeldet.")
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
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(.primary)

            if let quote = quoteViewModel.randomQuote {
                NavigationLink(destination: AutorDetailView(authorName: quote.author)) {
                    quoteCard(quote, backgroundColors: [Color.black.opacity(0.85), Color.blue.opacity(0.6)])
                }
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
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(quoteViewModel.quotes.shuffled().prefix(8), id: \.id) { quote in
                        NavigationLink(destination: AutorDetailView(authorName: quote.author)) {
                            quoteCard(quote, backgroundColors: [Color.pink.opacity(0.8), Color.blue.opacity(0.7)])
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.trailing, 20)
            }
        }
    }

    // MARK: - Gemeinsame Zitat-Karte (Optimiert für Zitat des Tages und empfohlene Zitate)
    private func quoteCard(_ quote: Quote, backgroundColors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                WebImage(url: URL(string: quote.authorImageURLs?.first ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .shadow(radius: 3)

                VStack(alignment: .leading, spacing: 6) {
                    Text("„\(quote.quote)“")
                        .font(.system(.body, design: .serif))
                        .italic()
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .lineLimit(5)

                    Text("- \(quote.author)")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20) // Sanftere Ecken für eleganteres Aussehen
        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6) // Mehr Tiefe durch größeren Schatten
    }

    // MARK: - Neues Zitat-Button
    private var newQuoteButton: some View {
        Button(action: {
            Task {
                await quoteViewModel.getRandomQuote()
            }
        }) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                Text("Neue Zitate laden")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
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
