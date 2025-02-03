//
//  ExplorerView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 28.01.25.
//

import SwiftUI

struct ExplorerView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel
    @State private var selectedCategory: String? = nil
    @State private var searchQuery: String = "" // Suchbegriff speichern
    @State private var isLoading: Bool = false // Ladeindikator
    @State private var errorMessage: String? = nil // Fehlernachricht speichern
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Explorer View")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Suchleiste für Autoren
                HStack {
                    TextField("Suche nach Autoren...", text: $searchQuery)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Button(action: {
                        // Sucht nach Zitaten direkt, wenn der Button gedrückt wird
                        searchQuotes()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .padding([.leading, .trailing])

                // Fehlernachricht anzeigen
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }

                // Anzeige der Zitate
                if isLoading {
                    ProgressView("Lade Zitate...") // Ladeindikator
                        .padding()
                } else {
                    List(quoteViewModel.quotes, id: \.id) { quote in
                        VStack(alignment: .leading) {
                            Text(quote.quote)
                                .font(.body)
                                .padding(.bottom, 2)
                            
                            Text("- \(quote.author)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            // NavigationLink zu AutorDetailView
                            NavigationLink(destination: AutorDetailView(quote: quote, quoteViewModel: quoteViewModel)) {
                                Text("Mehr über \(quote.author)")
                                    .font(.body)
                                    .foregroundColor(.blue)
                                    .padding(.top, 5)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
    
    private func searchQuotes() {
        // Überprüfen, ob der Suchbegriff leer ist, falls ja, tue nichts
        guard !searchQuery.isEmpty else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        // Aufruf der vorhandenen searchQuotes-Funktion im ViewModel
        Task {
            // Suche nach Zitaten mit dem eingegebenen Suchbegriff
            await quoteViewModel.searchQuotes(query: searchQuery)
            isLoading = false
        }
    }
    

}

#Preview {
    ExplorerView(quoteViewModel: QuoteViewModel())
}
