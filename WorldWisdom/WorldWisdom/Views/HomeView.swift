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

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // **Willkommensnachricht** und **Benutzerinfo**
                VStack(alignment: .leading, spacing: 10) {
                    Text("Willkommen zur HomeView!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top)

                    if let user = userViewModel.user {
                        Text(user.email ?? "Anonym angemeldet. UID: \(user.uid)")
                            .font(.subheadline)
                            .foregroundColor(user.email != nil ? .green : .blue)
                            .padding(.horizontal)
                    }
                }

                // **Fehleranzeige**, falls ein Fehler aufgetreten ist
                if let errorMessage = quoteViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                // **Zitat des Tages**
                if let quote = quoteViewModel.randomQuote {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Zitat des Tages")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(quote.quote)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.bottom, 5)
                            .lineLimit(3)

                        Text("- \(quote.author)")
                            .font(.footnote)
                            .foregroundColor(.gray)

                        // **Favoriten-Button**
                        Button(action: {
                            Task {
                                let isFavorite = !(quote.isFavorite ?? false)
                                await quoteViewModel.updateFavoriteStatus(for: quote, isFavorite: isFavorite)
                            }
                        }) {
                            HStack {
                                Image(systemName: quote.isFavorite ?? false ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                Text(quote.isFavorite ?? false ? "Favorit entfernen" : "Favorisieren")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                } else {
                    Text("Lädt Zitat des Tages...")
                        .padding()
                        .foregroundColor(.gray)
                }

                // **Empfohlene Zitate (Inspirations-Feed)**
                VStack(alignment: .leading, spacing: 10) {
                    Text("Empfohlene Zitate")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(quoteViewModel.quotes.prefix(5), id: \.id) { quote in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(quote.quote)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                        .padding()

                                    Text("- \(quote.author)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 250)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // **Button für neues zufälliges Zitat**
                Button(action: {
                    Task {
                        quoteViewModel.getRandomQuote() // Holt ein zufälliges Zitat aus den bereits geladenen Zitaten
                    }
                }) {
                    Text("Lade ein zufälliges Zitat")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.vertical)
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
