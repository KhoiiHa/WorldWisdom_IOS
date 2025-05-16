//
//  HomeView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI
import Foundation

// Startbildschirm der App.
// Zeigt eine Willkommensnachricht, Zitat des Tages, empfohlene Zitate, einen Fun Fact und einen Button zum Laden neuer Inhalte.
// Bindet sowohl Firebase-Daten als auch lokale Daten über QuoteViewModel ein.

// MARK: - HomeView
struct HomeView: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var quoteViewModel = QuoteViewModel()
    @State private var randomAuthorFact: (author: String, fact: String)? = nil
    @State private var recommendedQuotes: [Quote] = []
    @State private var selectedQuote: Quote?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // MARK: Willkommen
                    welcomeSection

                    // MARK: Zitat des Tages
                    dailyQuoteSection
                        .background(Color("cardBackground"))
                        .cornerRadius(16)
                        .shadow(color: Color("primaryText").opacity(0.15), radius: 5, x: 0, y: 2)

                    // MARK: Empfohlene Zitate
                    recommendedQuotesSection
                        .background(Color("cardBackground"))
                        .cornerRadius(16)
                        .shadow(color: Color("primaryText").opacity(0.15), radius: 5, x: 0, y: 2)

                    // MARK: Fun Fact zum Autor
                    authorFactSection
                        .background(Color("cardBackground"))
                        .cornerRadius(16)
                        .shadow(color: Color("primaryText").opacity(0.15), radius: 5, x: 0, y: 2)

                    // MARK: Button für neue Zitate
                    newQuoteButton
                }
                .padding(20)
            }
            .navigationTitle("Home")
            .background(Color("background"))
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
                    if let (author, facts) = AuthorFunFacts.facts.randomElement(),
                       let fact = facts.randomElement() {
                        randomAuthorFact = (author: author, fact: fact)
                    }
                }
            }
        }
        .navigationDestination(item: $selectedQuote) { quote in
            AutorDetailView(authorName: quote.author)
        }
    }

    // MARK: - Willkommen
    // Zeigt eine Willkommensnachricht und die E-Mail des Nutzers (oder Hinweis auf anonym)
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Willkommen zurück!")
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .foregroundColor(Color("mainBlue"))
                .padding(.bottom, 10)

            // Handle optional email with fallback text
            if let user = userViewModel.user {
                Text(user.email ?? "Nutzer ist Anonym angemeldet.")
                    .font(.subheadline)
                    .foregroundColor(user.email != nil ? Color("buttonColor") : Color("mainBlue"))
                    .opacity(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Zitat des Tages
    // Zeigt das zufällige Zitat des Tages an oder einen Lade-Indikator
    private var dailyQuoteSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Zitat des Tages")
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(Color("mainBlue"))

            if let quote = quoteViewModel.randomQuote {
                Button {
                    selectedQuote = quote
                } label: {
                    dailyQuoteCard(quote, backgroundColors: [Color("mainBlue").opacity(0.85), Color("buttonColor").opacity(0.6)])
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                ProgressView("Lädt Zitat des Tages...")
                    .foregroundColor(Color("secondaryText"))
                    .padding()
            }

            // Fehleranzeige nur wenn keine Zitate vorhanden sind
            if let errorMessage = quoteViewModel.errorMessage, quoteViewModel.quotes.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(Color("buttonColor"))
                    .padding()
            }

            Text("💡 Tipp: Tippe auf das Zitat, um mehr über den Autor zu erfahren.")
                .font(.caption)
                .foregroundColor(Color("secondaryText"))
                .padding(.top, 4)
        }
        .padding()
    }

    // MARK: - Empfohlene Zitate
    // Horizontale Liste mit empfohlenen Zitaten
    private var recommendedQuotesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Empfohlene Zitate")
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(Color("mainBlue"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(recommendedQuotes.prefix(8), id: \.id) { quote in
                        Button {
                            selectedQuote = quote
                        } label: {
                            recommendedQuoteCard(quote, backgroundColors: [Color("buttonColor").opacity(0.8), Color("mainBlue").opacity(0.7)])
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.trailing, 20)
            }
            .background(Color("cardBackground").opacity(0.1))
        }
        .padding()
    }

    // MARK: - Fun Fact zum Autor
    // Zeigt einen zufälligen Fun Fact zum Autor mit Aktualisierungsbutton
    private var authorFactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Wusstest du schon?")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color("mainBlue"))

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if let (author, facts) = AuthorFunFacts.facts.randomElement(),
                           let fact = facts.randomElement() {
                            randomAuthorFact = (author: author, fact: fact)
                        }
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color("buttonColor"))
                }
            }

            if let factItem = randomAuthorFact {
                Label {
                    Text("**\(factItem.author)**: \(factItem.fact)")
                } icon: {
                    Image(systemName: "lightbulb")
                        .foregroundColor(Color("buttonColor"))
                }
                .font(.body)
                .foregroundColor(Color("secondaryText"))
            }
        }
        .padding()
    }

    // MARK: - Zitat des Tages Karte
    // Gestaltung der Karte für das Zitat des Tages
    private func dailyQuoteCard(_ quote: Quote, backgroundColors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("„\(quote.quote)“")
                .font(.system(.body, design: .serif))
                .italic()
                .multilineTextAlignment(.leading)
                .foregroundColor(Color("primaryText"))
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
                    .foregroundColor(Color("primaryText").opacity(0.85))
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
                .stroke(Color("primaryText").opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color("primaryText").opacity(0.3), radius: 8, x: 0, y: 4)
    }

    // MARK: - Empfohlenes Zitat Karte
    // Gestaltung der Karte für empfohlene Zitate
    private func recommendedQuoteCard(_ quote: Quote, backgroundColors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("„\(quote.quote)“")
                .font(.system(.body, design: .serif))
                .italic()
                .multilineTextAlignment(.leading)
                .foregroundColor(Color("primaryText"))
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
                    .foregroundColor(Color("primaryText").opacity(0.85))
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
                .stroke(Color("primaryText").opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color("primaryText").opacity(0.3), radius: 8, x: 0, y: 4)
    }

    // MARK: - Neues Zitat-Button
    // Button zum Laden neuer Zitate
    private var newQuoteButton: some View {
        Button(action: {
            Task {
                await quoteViewModel.getRandomQuote()
                recommendedQuotes = quoteViewModel.quotes.shuffled()
            }
        }) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Color("primaryText"))
                Text("Neue Zitate laden")
                    .font(.headline)
                    .foregroundColor(Color("primaryText"))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("mainBlue").opacity(0.8), Color("buttonColor").opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: Color("mainBlue").opacity(0.3), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Laden der Zitate mit Fehlerbehandlung
    // Lädt alle Zitate und behandelt Fehler
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
