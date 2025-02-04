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
            VStack {
                // 🔍 Suchleiste
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Suche nach Autoren oder Zitaten...", text: $searchQuery)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // 🏷️ Tag-Filter (ScrollView mit Tags)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(allTags, id: \.self) { tag in
                            Button(action: {
                                selectedTag = (selectedTag == tag) ? nil : tag // Toggle-Funktion
                            }) {
                                Text(tag)
                                    .padding(10)
                                    .background(selectedTag == tag ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedTag == tag ? .white : .black)
                                    .cornerRadius(15)
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
            }
            .navigationTitle("Entdecke Zitate")
            .task {
                await quoteViewModel.loadAllQuotes() // Aufruf direkt beim Start
            }
        }
    }
}

// 📌 Verbesserte Quote Card
struct QuoteCardView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.quote)
                .font(.body)
                .foregroundColor(.primary)

            Text("- \(quote.author)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ExplorerView(quoteViewModel: QuoteViewModel())
}
