//
//  HomeView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//
import SwiftUI
import SwiftData
import SDWebImageSwiftUI
import Foundation // falls nicht vorhanden

struct HomeView: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var quoteViewModel = QuoteViewModel()
    @State private var randomAuthorFact: (author: String, fact: String)? = nil
    @State private var recommendedQuotes: [Quote] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    welcomeSection
                    dailyQuoteSection
                    recommendedQuotesSection
                    authorFactSection
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
                if recommendedQuotes.isEmpty {
                    recommendedQuotes = quoteViewModel.quotes.shuffled()
                }
                if randomAuthorFact == nil {
                    if let random = AuthorFacts.facts.randomElement() {
                        randomAuthorFact = (author: random.key, fact: random.value)
                    }
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
                    dailyQuoteCard(quote, backgroundColors: [Color.black.opacity(0.85), Color.blue.opacity(0.6)])
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
                    ForEach(recommendedQuotes.prefix(8), id: \.id) { quote in
                        NavigationLink(destination: AutorDetailView(authorName: quote.author)) {
                            recommendedQuoteCard(quote, backgroundColors: [Color.pink.opacity(0.8), Color.blue.opacity(0.7)])
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.trailing, 20)
            }
        }
    }

    private var authorFactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Wusstest du schon?")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    if let random = AuthorFacts.facts.randomElement() {
                        randomAuthorFact = (author: random.key, fact: random.value)
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
            }

            if let factItem = randomAuthorFact {
                Text("**\(factItem.author)**: \(factItem.fact)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Zitat des Tages Karte
    private func dailyQuoteCard(_ quote: Quote, backgroundColors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("„\(quote.quote)“")
                .font(.system(.body, design: .serif))
                .italic()
                .multilineTextAlignment(.leading)
                .foregroundColor(.white)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center, spacing: 10) {
                WebImage(url: URL(string: quote.authorImageURLs?.first ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .shadow(radius: 3)

                Text("- \(quote.author)")
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding()
        .frame(maxWidth: 320)
        .background(
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }

    // MARK: - Empfohlenes Zitat Karte
    private func recommendedQuoteCard(_ quote: Quote, backgroundColors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("„\(quote.quote)“")
                .font(.system(.body, design: .serif))
                .italic()
                .multilineTextAlignment(.leading)
                .foregroundColor(.white)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center, spacing: 10) {
                WebImage(url: URL(string: quote.authorImageURLs?.first ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .shadow(radius: 3)

                Text("- \(quote.author)")
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding()
        .frame(width: 320) // explizit feste Breite für horizontales Scrollen
        .background(
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }

    // MARK: - Neues Zitat-Button
    private var newQuoteButton: some View {
        Button(action: {
            Task {
                await quoteViewModel.getRandomQuote()
                recommendedQuotes = quoteViewModel.quotes.shuffled()
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
            .frame(maxWidth: 320)
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
