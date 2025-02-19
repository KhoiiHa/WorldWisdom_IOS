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
                HomeView(userViewModel: userViewModel)
            }

            // Explorer Tab
            Tab("Explorer", systemImage: "magnifyingglass") {
                ExplorerView(quoteViewModel: quoteViewModel)
            }

            // Favorites Tab
            Tab("Favorites", systemImage: "heart") {
                FavoriteView()
            }

            // Gallery Tab
            Tab("Gallery", systemImage: "photo.on.rectangle.angled") {
                if let authorId = userViewModel.user?.authorId {
                    // Direkt die authorId übergeben, wenn der User eingeloggt ist
                    GalerieScreen(authorId: authorId)
                } else {
                    // Optional: Zeige einen Platzhalter oder eine Fehlermeldung, falls der user nicht eingeloggt ist
                    Text("Kein Benutzer gefunden")
                        .foregroundColor(.gray)
                }
            }

            // Settings Tab
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
