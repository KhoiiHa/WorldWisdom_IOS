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

                // Fehleranzeige, falls ein Fehler aufgetreten ist
                if let errorMessage = quoteViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // Zeige das zufällige Zitat, falls vorhanden
                if let quote = quoteViewModel.randomQuote {
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
                                // Toggle Favoritenstatus
                                let isFavorite = !(quote.isFavorite ?? false)
                                await quoteViewModel.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
                                print(isFavorite ? "Zitat als Favorit gespeichert!" : "Zitat aus Favoriten entfernt!")
                            }
                        }) {
                            HStack {
                                Image(systemName: quote.isFavorite ?? false ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                Text(quote.isFavorite ?? false ? "Favorit entfernen" : "Favorisieren")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle()) // Damit der Button wie gewünscht aussieht
                    }
                    .padding()
                } else {
                    // Anzeige, wenn das Zitat noch geladen wird oder es einen Fehler gibt
                    Text("Lädt Zitat...")
                        .padding()
                        .foregroundColor(.gray)
                }

                // Button für neues zufälliges Zitat
                Button(action: {
                    Task {
                        quoteViewModel.getRandomQuote() // Holt ein zufälliges Zitat aus den bereits geladenen Zitaten
                    }
                }) {
                    Text("Lade ein zufälliges Zitat")
                        .font(.body)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
        .onAppear {
            Task {
                // Falls die Zitate noch nicht geladen wurden, lade sie einmalig
                if quoteViewModel.quotes.isEmpty {
                    await quoteViewModel.loadAllQuotes()
                }
                quoteViewModel.getRandomQuote() // Wählt ein zufälliges Zitat aus den geladenen Daten
            }
        }
    }
}

#Preview {
    HomeView(userViewModel: UserViewModel())
}
