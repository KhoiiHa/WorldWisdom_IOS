//
//  ExplorerView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 28.01.25.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

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
                
                Button("Neue Zitate laden") {
                    Task {
                        await loadQuotes()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.horizontal)

                ScrollView {
                    LazyVStack(spacing: 15) {
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            if filteredQuotes.isEmpty {
                                Text("Keine passenden Zitate gefunden.")
                                    .foregroundColor(.white.opacity(0.8))
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

    @ViewBuilder
    private func quoteNavigationCard(for quote: Quote, at index: Int) -> some View {
        NavigationLink(destination: AutorDetailView(authorName: quote.author)) {
            QuoteCardView(quote: quote)
                .transition(.opacity.combined(with: .move(edge: .leading)))
                .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: filteredQuotes)
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
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.95)))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

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
                        .background(
                            RoundedRectangle(cornerRadius: 20).fill(selectedTag == nil ? Color.gray : Color.gray.opacity(0.5))
                        )
                        .foregroundColor(.white)
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
                                    .fill(selectedTag == tag ? Color.blue : randomTagColor(tag).opacity(0.8))
                            )
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
            showErrorMessage = quoteViewModel.quotes.isEmpty
        }
        isLoading = false
    }

    private func randomTagColor(_ tag: String) -> Color {
        let colors: [Color] = [.pink, .purple, .orange, .green, .blue, .cyan]
        return colors[abs(tag.hashValue) % colors.count]
    }
}

struct QuoteCardView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("„\(quote.quote)“")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundColor(.white)
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
                    .foregroundColor(.white.opacity(0.85))
            }

            if !quote.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quote.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.15))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.indigo.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    ExplorerView(quoteViewModel: QuoteViewModel())
}
