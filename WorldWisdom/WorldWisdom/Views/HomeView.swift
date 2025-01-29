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

                // Zitate anzeigen, falls vorhanden
                List(quoteViewModel.quotes) { quote in
                    VStack(alignment: .leading) {
                        Text(quote.quote)
                            .font(.body)
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
                    .padding(.vertical, 5)
                }

                // Picker zur Auswahl einer Kategorie
                Picker("Kategorie wählen", selection: $selectedCategory) {
                    Text("Alle Kategorien").tag(nil as String?)
                    ForEach(quoteViewModel.categories, id: \.self) { category in
                        Text(category).tag(category as String?)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedCategory, initial: true) { oldValue, newValue in
                    Task {
                        isLoading = true
                        if let category = newValue {
                            await quoteViewModel.loadQuotesByCategory(category: category)
                        } else {
                            await quoteViewModel.loadMultipleQuotes()
                        }
                        isLoading = false
                    }
                }

                // Button für neue zufällige Zitate
                Button("Lade zufällige Zitate") {
                    Task {
                        isLoading = true
                        await quoteViewModel.loadMultipleQuotes()
                        isLoading = false
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                // Button für EIN einzelnes zufälliges Zitat
                Button("Lade ein zufälliges Zitat") {
                    Task {
                        isLoading = true
                        await quoteViewModel.loadRandomQuote()
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
                await quoteViewModel.loadMultipleQuotes()
                await quoteViewModel.loadCategories() // Kategorien laden
                isLoading = false
            }
        }
    }
}

#Preview {
    HomeView(userViewModel: UserViewModel())
}
