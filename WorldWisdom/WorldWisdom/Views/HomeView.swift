//
//  HomeView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var quoteViewModel = QuoteViewModel() // ViewModel für Zitate
    @State private var isLoading = false // Ladeindikator
    @State private var selectedCategory: String? // Ausgewählte Kategorie

    var body: some View {
        NavigationStack {
            VStack {
                // Willkommensnachricht
                Text("Willkommen zur HomeView!")
                    .font(.largeTitle)
                    .padding()

                // Benutzerinfo
                if let user = userViewModel.user {
                    Text(user.email ?? "Anonym angemeldet. UID: \(user.uid)")
                        .padding()
                        .foregroundColor(user.email != nil ? .green : .blue)
                }

                // Falls Zitate gerade laden → Lade-Animation
                if isLoading {
                    ProgressView("Lade Zitate...")
                        .padding()
                }

                // Falls Fehler auftritt, zeige Fehlermeldung
                if let errorMessage = quoteViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // Zeige das zufällige Zitat, falls vorhanden
                if let quote = quoteViewModel.quotes.first {
                    VStack(alignment: .leading) {
                        Text(quote.quote)
                            .font(.body)
                            .padding(.bottom, 5)
                        Text("- \(quote.author)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        // Favoriten-Button
                        Button(action: {
                            Task {
                                do {
                                    try await FirebaseManager.shared.saveFavoriteQuote(quote: quote)
                                    print("Zitat als Favorit gespeichert!")
                                } catch {
                                    print("Fehler beim Speichern: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            Text("Favorisieren")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                }

                // Button für ein zufälliges Zitat
                Button("Lade ein zufälliges Zitat") {
                    Task {
                        isLoading = true
                        await quoteViewModel.loadRandomQuote() // Lade ein zufälliges Zitat
                        isLoading = false
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
        .onAppear {
            Task {
                isLoading = true
                await quoteViewModel.loadRandomQuote() // Beim Start ein zufälliges Zitat laden
                await quoteViewModel.loadCategories() // Kategorien laden (falls benötigt)
                isLoading = false
            }
        }
    }
}

#Preview {
    HomeView(userViewModel: UserViewModel())
}
