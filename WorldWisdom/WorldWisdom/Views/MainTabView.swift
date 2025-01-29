//
//  MainTabView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 29.01.25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var userViewModel = UserViewModel() // UserViewModel für die Benutzerverwaltung
    @StateObject var quoteViewModel = QuoteViewModel() // QuoteViewModel für Zitateverwaltung

    var body: some View {
        TabView {
            // Home Tab
            Tab("Home", systemImage: "house") {
                HomeView(userViewModel: userViewModel) // Übergabe von userViewModel
            }

            // Explorer Tab
            Tab("Explorer", systemImage: "magnifyingglass") {
                ExplorerView(quoteViewModel: quoteViewModel) 
            }

            // Favorites Tab
            Tab("Favorites", systemImage: "heart") {
                FavoriteView() // Favoriten-Ansicht
            }

            // Author Details Tab
            Tab("Author Details", systemImage: "person.text.rectangle") {
                AutorDetailView(
                    quote: Quote(
                        id: UUID().uuidString, // Ein zufälliger UUID als Beispiel
                        author: "John Doe", quote: "Sample quote",
                        category: "Motivation", // Beispiel Kategorie
                        tags: ["inspiration", "life"], // Beispiel Tags
                        isFavorite: false, // Beispiel: Zitat ist nicht favorisiert
                        source: "Wikipedia" // Beispiel Quelle
                    ),
                    quoteViewModel: QuoteViewModel() // Übergabe des QuoteViewModels
                )
            }

            // Settings Tab
            Tab("Settings", systemImage: "gear") {
                SettingsView() // Einstellungen-Ansicht
            }
        }
    }
}

#Preview {
    MainTabView()
}
