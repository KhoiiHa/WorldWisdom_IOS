//
//  HomeView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//
import SwiftUI

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
                    await quoteViewModel.loadAllQuotes()
                }
                quoteViewModel.getRandomQuote()
            }
        }
    }

    // MARK: - Willkommensnachricht
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Willkommen zurück!")
                .font(.largeTitle).bold()

            if let user = userViewModel.user {
                Text(user.email ?? "Anonym angemeldet. UID: \(user.uid)")
                    .font(.subheadline)
                    .foregroundColor(user.email != nil ? .green : .blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Zitat des Tages
    private var dailyQuoteSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Zitat des Tages")
                .font(.title2).bold()

            if let quote = quoteViewModel.randomQuote {
                // Navigiere zur Detailansicht des Zitats
                NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: quoteViewModel)) {
                    quoteCard(quote)
                }
                
                Button(action: {
                    Task {
                        let isFavorite = !(quote.isFavorite)
                        await quoteViewModel.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
                    }
                }) {
                    HStack {
                        Image(systemName: quote.isFavorite ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                        Text(quote.isFavorite ? "Favorit entfernen" : "Favorisieren")
                            .font(.caption)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                ProgressView("Lädt Zitat des Tages...").padding()
            }
        }
    }

    // MARK: - Empfohlene Zitate
    private var recommendedQuotesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Empfohlene Zitate")
                .font(.title2).bold()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Navigiere zur Detailansicht des Zitats
                    ForEach(quoteViewModel.quotes.prefix(5), id: \.id) { quote in
                        NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: quoteViewModel)) {
                            quoteCard(quote)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Zitat-Karte
    private func quoteCard(_ quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("„\(quote.quote)“")
                .font(.body)
                .italic()
                .lineLimit(3)

            Text("- \(quote.author)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 250, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // MARK: - Neues Zitat-Button
    private var newQuoteButton: some View {
        Button(action: { Task { quoteViewModel.getRandomQuote() } }) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                Text("Neues Zitat laden").font(.headline)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(15)
            .shadow(color: .blue.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    HomeView(userViewModel: UserViewModel())
}
