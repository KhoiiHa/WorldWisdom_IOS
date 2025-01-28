//
//  HomeView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var isLoggedOut = false
    @StateObject private var quoteViewModel = QuoteViewModel() // Hinzufügen des QuoteViewModels
    @State private var isLoading = false // Ladeindikator
    
    var body: some View {
        NavigationStack {
            VStack {
                // Willkommensnachricht
                Text("Willkommen zur HomeView!")
                    .font(.largeTitle)
                    .padding()

                // Benutzerinfo anzeigen
                if let user = userViewModel.user {
                    if let email = user.email {
                        Text("Angemeldeter Benutzer: \(email)")
                            .padding()
                            .foregroundColor(.green)
                    } else {
                        Text("Anonym angemeldet. UID: \(user.uid)")
                            .padding()
                            .foregroundColor(.blue)
                    }
                }

                // Anzeige der Zitate
                if isLoading {
                    ProgressView("Lade Zitate...") // Ladeindikator
                        .padding()
                } else {
                    if let errorMessage = quoteViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        List(quoteViewModel.quotes) { quote in
                            VStack(alignment: .leading) {
                                Text(quote.quote)
                                    .font(.body)
                                Text("- \(quote.author)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                // Button, um Zitat als Favorit zu speichern
                                Button(action: {
                                    Task {
                                        do {
                                            try await FirebaseManager.shared.saveFavoriteQuote(quote: quote)
                                            print("Zitat erfolgreich als Favorit gespeichert!")
                                        } catch {
                                            print("Fehler beim Speichern des Favoriten: \(error.localizedDescription)")
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
                    }
                }

                // Button zum Abrufen zufälliger Zitate
                Button("Lade zufällige Zitate") {
                    Task {
                        isLoading = true
                        await quoteViewModel.loadRandomQuote() // Lädt ein zufälliges Zitat
                        isLoading = false
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top)

                Spacer()

                // Abmelden-Button
                Button("Abmelden") {
                    Task {
                        await userViewModel.signOut()
                        isLoggedOut = true
                    }
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .navigationDestination(isPresented: $isLoggedOut) {
                AuthenticationView()
            }
        }
        .onAppear {
            Task {
                await quoteViewModel.loadMultipleQuotes() // Zitate beim Laden der View abrufen
            }
        }
    }
}

#Preview {
    HomeView(userViewModel: UserViewModel())
}
