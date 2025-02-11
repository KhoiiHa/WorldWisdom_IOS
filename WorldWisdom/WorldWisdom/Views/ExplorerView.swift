//
//  ExplorerView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 28.01.25.
//

import SwiftUI

struct ExplorerView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel
    @State private var searchQuery: String = ""
    @State private var selectedTag: String? = nil // Aktuell ausgewählter Tag
    @State private var showErrorMessage: Bool = false // Fehleranzeige

    // Alle einzigartigen Tags für die Filter-Buttons
    private var allTags: [String] {
        let tags = quoteViewModel.quotes.flatMap { $0.tags }
        return Array(Set(tags)).sorted() // Entfernt doppelte Tags & sortiert sie
    }

    // Gefilterte Zitate basierend auf Suche & Tag-Filter
    private var filteredQuotes: [Quote] {
        return quoteViewModel.quotes.filter { quote in
            let matchesSearch = searchQuery.isEmpty || quote.author.localizedCaseInsensitiveContains(searchQuery) || quote.quote.localizedCaseInsensitiveContains(searchQuery)
            let matchesTag = selectedTag == nil || quote.tags.contains(selectedTag!) // Tag-Filter
            return matchesSearch && matchesTag
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                // 📌 Neue optimierte Suchleiste
                searchBar

                // 🏷️ Tag-Filter (ScrollView mit Tags)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(allTags, id: \.self) { tag in
                            Button(action: {
                                selectedTag = (selectedTag == tag) ? nil : tag // Toggle-Funktion
                            }) {
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
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

                // 📜 Zitate-Liste als ScrollView
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
                .scrollIndicators(.hidden) // Versteckt Scroll-Indikatoren
                
                // Fehlermeldung, falls etwas schiefgeht
                if showErrorMessage {
                    Text("Fehler beim Laden der Zitate. Bitte versuchen Sie es später erneut.")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Entdecke Zitate")
            .task {
                await loadQuotes() // Lädt Zitate beim Start
            }
        }
    }

    // MARK: - Neue Suchleiste
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Suche nach Autoren oder Zitaten...", text: $searchQuery)
                .foregroundColor(.primary)
                .onChange(of: searchQuery) {
                    // Reset der Tag-Auswahl bei Änderung der Suche
                    selectedTag = nil
                    // Async Call innerhalb eines Task Blocks
                    Task {
                        await loadQuotes() // Ruft loadQuotes auf, wenn der Suchbegriff geändert wird
                    }
                }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Lädt Zitate mit Fehlerbehandlung
    private func loadQuotes() async {
        do {
            // Versuche, alle Zitate zu laden
            try await quoteViewModel.loadAllQuotes()
            showErrorMessage = false  // Fehleranzeige zurücksetzen
        } catch {
            // Fehler beim Laden der Zitate
            print("Fehler beim Laden der Zitate: \(error.localizedDescription)")
            showErrorMessage = true
        }
    }
}

// 📌 Verbesserte Quote Card
struct QuoteCardView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("„\(quote.quote)“")
                .font(.body)
                .italic()
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

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
}

#Preview {
    ExplorerView(quoteViewModel: QuoteViewModel())
}
