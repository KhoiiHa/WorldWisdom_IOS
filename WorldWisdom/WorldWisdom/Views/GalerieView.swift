//
//  GalerieView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 14.02.25.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

struct GalerieScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query var quotes: [QuoteEntity]
    @State private var searchText: String = ""

    var uniqueAuthors: [(author: String, imageUrl: String?)] {
        var result: [(String, String?)] = []
        let grouped = Dictionary(grouping: quotes) { $0.author }
        for (author, items) in grouped {
            let url = items.first?.authorImageURLs.first
            result.append((author, url))
        }
        return result.sorted { $0.0.localizedCaseInsensitiveCompare($1.0) == .orderedAscending }
    }

    var filteredAuthors: [(author: String, imageUrl: String?)] {
        if searchText.isEmpty {
            return uniqueAuthors
        } else {
            return uniqueAuthors.filter {
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                TextField("Autor suchen", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(filteredAuthors, id: \.author) { item in
                            NavigationLink(destination: AutorDetailView(authorName: item.author)) {
                                VStack {
                                    WebImage(url: URL(string: item.imageUrl ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)

                                    Text(item.author)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .frame(width: 80)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
