//
//  ExplorerView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 28.01.25.
//

/// Zeigt eine durchsuchbare, filterbare Liste inspirierender Zitate mit Kategorien, Autorenbildern und Favoritenstatus.
import SwiftUI
import SDWebImageSwiftUI


struct ExplorerView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel
    @State private var searchQuery: String = ""
    @State private var selectedTag: String? = nil
    @State private var showErrorMessage: Bool = false
    @State private var isLoading: Bool = false
    @State private var selectedQuote: Quote?

    private var allTags: [String] {
        let tags = quoteViewModel.quotes.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }

    private var filteredQuotes: [Quote] {
        return quoteViewModel.quotes.filter { quote in
            let matchesSearch = searchQuery.isEmpty || quote.author.localizedCaseInsensitiveContains(searchQuery) || quote.quote.localizedCaseInsensitiveContains(searchQuery)
            let matchesTag = selectedTag == nil || quote.tags.contains(selectedTag!)
            return matchesSearch && matchesTag
        }
    }

    // MARK: - View Body (Hauptansicht)
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                searchBar
                tagFilterView

                ScrollView {
                    LazyVStack(spacing: 15) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            if filteredQuotes.isEmpty {
                                Text("Keine passenden Zitate gefunden.")
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .multilineTextAlignment(.center)
                            } else {
                                ForEach(filteredQuotes.indices, id: \.self) { index in
                                    quoteNavigationCard(for: filteredQuotes[index], at: index)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await loadQuotes()
                }

                if showErrorMessage {
                    errorMessageView
                }
            }
            .navigationTitle("Inspiration entdecken")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await loadQuotes() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
            }
            .font(.title3.bold())
            .foregroundColor(Color("primaryText"))
            .background(
                Color("background").ignoresSafeArea()
            )
            .task {
                await loadQuotes()
            }
            .navigationDestination(item: $selectedQuote) { quote in
                AutorDetailView(authorName: quote.author)
            }
        }
    }

    // MARK: - Zitatkarten-Navigation (Navigation zu Detailansicht)
    @ViewBuilder
    private func quoteNavigationCard(for quote: Quote, at index: Int) -> some View {
        Button {
            selectedQuote = quote
        } label: {
            QuoteCardView(quote: quote)
                .transition(.opacity.combined(with: .move(edge: .leading)))
                .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: filteredQuotes)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Suchleiste (Sucheingabe)
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("secondaryText"))
            
            TextField("Suche nach Zitaten oder Autoren...", text: $searchQuery)
                .font(.subheadline)
                .foregroundColor(Color("primaryText"))
                .onChange(of: searchQuery) { _, _ in
                    selectedTag = nil
                    Task { await loadQuotes() }
                }
        }
        .padding(12)
        .background(Color("cardBackground"))
        .cornerRadius(20)
        .shadow(color: Color("buttonColor").opacity(0.10), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Tag-Filter (Filterleiste)
    private var tagFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button(action: {
                    withAnimation {
                        selectedTag = nil
                    }
                }) {
                    Text("Alle")
                        .font(.subheadline)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .foregroundColor(Color("primaryText"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedTag == nil ? Color("mainBlue") : Color.clear, lineWidth: 2)
                        )
                }
                ForEach(allTags, id: \.self) { tag in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            selectedTag = (selectedTag == tag) ? nil : tag
                        }
                    }) {
                        Text(tag)
                            .font(.subheadline)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedTag == tag ? Color("mainBlue") : randomTagColor(tag).opacity(0.8))
                            )
                            .foregroundColor(Color("primaryText"))
                            .cornerRadius(20)
                            .shadow(color: Color("buttonColor").opacity(0.10), radius: 2, x: 0, y: 2)
                            .scaleEffect(selectedTag == tag ? 1.1 : 1.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedTag == tag ? Color("cardBackground") : Color.clear, lineWidth: 2)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Fehlermeldung (Fehleranzeige)
    private var errorMessageView: some View {
        Text("Fehler beim Laden der Zitate. Bitte versuchen Sie es später erneut.")
            .foregroundColor(.red)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(8)
            .padding(.horizontal)
    }

    // MARK: - Ladefunktion für Zitate (Async Laden)
    private func loadQuotes() async {
        isLoading = true
        do {
            try await quoteViewModel.loadAllQuotes()
            quoteViewModel.quotes = quoteViewModel.quotes.shuffled()
            showErrorMessage = false
        } catch {
            showErrorMessage = quoteViewModel.quotes.isEmpty
        }
        isLoading = false
    }

    // MARK: - Farblogik für Tags (Systemfarben)
    private func randomTagColor(_ tag: String) -> Color {
        let colors: [Color] = [.pink, .purple, .orange, .green, .blue, .cyan]
        return colors[abs(tag.hashValue) % colors.count]
    }
}

// MARK: - Einzelne Zitatkarte (Kartenansicht)
struct QuoteCardView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.title2)
                    .foregroundColor(Color("secondaryText"))
                Spacer()
            }
            Text("„\(quote.quote)“")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundColor(Color("primaryText"))
                .multilineTextAlignment(.leading)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center, spacing: 10) {
                WebImage(url: URL(string: quote.authorImageURLs?.first ?? "https://via.placeholder.com/100"))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .shadow(radius: 3)

                Text("- \(quote.author)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Color("secondaryText"))
                    .padding(.leading, 4)
            }

            if !quote.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quote.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .foregroundColor(Color("primaryText"))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            // Verlauf zwischen Asset-Farben für Kartenhintergrund
            LinearGradient(
                gradient: Gradient(colors: [Color("mainBlue").opacity(0.7), Color("buttonColor").opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
        .shadow(color: Color("buttonColor").opacity(0.13), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    ExplorerView(quoteViewModel: QuoteViewModel())
}
