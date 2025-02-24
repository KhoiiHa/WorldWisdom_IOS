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
                    quoteViewModel.getRandomQuote()
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
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(.primary)

            if let quote = quoteViewModel.randomQuote {
                NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: quoteViewModel)) {
                    quoteCard(quote)
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
                        NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: quoteViewModel)) {
                            recommendedQuoteCard(quote)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.trailing, 20)
            }
        }
    }

    // MARK: - Zitat-Karte (für Zitat des Tages)
    private func quoteCard(_ quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "quote.bubble.fill") // Icon für Zitate
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
                
                Text("„\(quote.quote)“")
                    .font(.body)
                    .italic()
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                    .lineLimit(4)
            }

            Text("- \(quote.author)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    // MARK: - Zitat-Karte (für empfohlene Zitate)
    private func recommendedQuoteCard(_ quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
               
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
                
                // Zitat-Text
                Text("„\(quote.quote)“")
                    .font(.body)
                    .italic()
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                    .lineLimit(4)
            }

            // Autorenname
            Text("- \(quote.author)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(width: 250) 
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    // MARK: - Neues Zitat-Button
    private var newQuoteButton: some View {
        Button(action: { Task { quoteViewModel.getRandomQuote() } }) {
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
