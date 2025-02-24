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
    @State private var isLoading: Bool = false

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

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                searchBar
                
                tagFilterView

                ScrollView {
                    LazyVStack(spacing: 15) {
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            ForEach(filteredQuotes.indices, id: \.self) { index in
                                NavigationLink(destination: AutorDetailView(quote: filteredQuotes[index], quoteViewModel: quoteViewModel)) {
                                    QuoteCardView(quote: filteredQuotes[index])
                                        .transition(.opacity.combined(with: .move(edge: .leading)))
                                        .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: filteredQuotes)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)

                if showErrorMessage {
                    errorMessageView
                }
            }
            .navigationTitle("Inspiration entdecken")
            .font(.title3.bold())
            .foregroundColor(.primary)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("BackgroundStart"), Color("BackgroundEnd")]),
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

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Suche nach Zitaten oder Autoren...", text: $searchQuery)
                .font(.subheadline)
                .foregroundColor(.primary)
                .onChange(of: searchQuery) { _, _ in
                    selectedTag = nil
                    Task { await loadQuotes() }
                }
        }
        .padding(12)
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    private var tagFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
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
                            .background(selectedTag == tag ? Color.blue : randomTagColor(tag))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                            .scaleEffect(selectedTag == tag ? 1.1 : 1.0)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var errorMessageView: some View {
        Text("Fehler beim Laden der Zitate. Bitte versuchen Sie es später erneut.")
            .foregroundColor(.white)
            .padding()
            .background(Color.red.opacity(0.8))
            .cornerRadius(8)
            .padding(.horizontal)
    }

    private func loadQuotes() async {
        isLoading = true
        do {
            try await quoteViewModel.loadAllQuotes()
            quoteViewModel.quotes = quoteViewModel.quotes.shuffled()
            showErrorMessage = false
        } catch {
            showErrorMessage = true
        }
        isLoading = false
    }
    
    private func randomTagColor(_ tag: String) -> Color {
        let colors: [Color] = [.pink, .purple, .orange, .green, .blue, .cyan]
        return colors[abs(tag.hashValue) % colors.count]
    }
}

// Verbesserte Quote Card mit dunklerer Schriftfarbe und harmonischem Farbverlauf
struct QuoteCardView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("„\(quote.quote)“")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundColor(Color.white.opacity(0.80))  
                .multilineTextAlignment(.leading)

            Text("- \(quote.author)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)

            // Tags anzeigen
            if !quote.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quote.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.orange.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.green.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ExplorerView(quoteViewModel: QuoteViewModel())
}
