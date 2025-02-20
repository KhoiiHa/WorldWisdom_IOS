//
//  ExplorerView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 28.01.25.
//

import SwiftUI
import SwiftData

struct ExplorerView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel
    @State private var searchQuery: String = ""
    @State private var selectedTag: String? = nil
    @State private var showErrorMessage: Bool = false

    // Alle einzigartigen Tags für die Filter-Buttons
    private var allTags: [String] {
        let tags = quoteViewModel.quotes.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }

    // Gefilterte Zitate basierend auf Suche & Tag-Filter
    private var filteredQuotes: [Quote] {
        return quoteViewModel.quotes.filter { quote in
            let matchesSearch = searchQuery.isEmpty || quote.author.localizedCaseInsensitiveContains(searchQuery) || quote.quote.localizedCaseInsensitiveContains(searchQuery)
            let matchesTag = selectedTag == nil || quote.tags.contains(selectedTag!)
            return matchesSearch && matchesTag
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                // Neue optimierte Suchleiste
                searchBar

                // Tag-Filter (ScrollView mit Tags)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(allTags, id: \.self) { tag in
                            Button(action: {
                                selectedTag = (selectedTag == tag) ? nil : tag
                            }) {
                                Text(tag)
                                    .font(.subheadline)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(selectedTag == tag ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedTag == tag ? .white : .primary)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Zitate-Liste als ScrollView
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredQuotes, id: \.id) { quote in
                            NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: quoteViewModel)) {
                                QuoteCardView(quote: quote)
                            }
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)

                // Fehlermeldung, falls etwas schiefgeht
                if showErrorMessage {
                    Text("Fehler beim Laden der Zitate. Bitte versuchen Sie es später erneut.")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Entdecke Zitate")
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.90, green: 0.92, blue: 0.96)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .task {
                await loadQuotes()
            }
        }
    }

    // MARK: - Neue Suchleiste
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Suche nach Autoren oder Zitaten...", text: $searchQuery)
                .font(.subheadline)
                .foregroundColor(.primary)
                .onChange(of: searchQuery) { _, newValue in
                    selectedTag = nil
                    Task {
                        await loadQuotes()
                    }
                }
        }
        .padding(12)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Lädt Zitate mit Fehlerbehandlung
    private func loadQuotes() async {
        do {
            try await quoteViewModel.loadAllQuotes()
            showErrorMessage = false
        } catch {
            print("Fehler beim Laden der Zitate: \(error.localizedDescription)")
            showErrorMessage = true
        }
    }
}

// Verbesserte Quote Card
struct QuoteCardView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("„\(quote.quote)“")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            Text("- \(quote.author)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ExplorerView(quoteViewModel: QuoteViewModel())
}
