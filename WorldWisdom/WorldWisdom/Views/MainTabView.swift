//
//  MainTabView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 29.01.25.
//

import SwiftUI

/// Haupt-Navigationsansicht mit fünf Tabs: Home, Explorer, Favorites, Galerie und Settings.
/// Jeder Tab lädt eine eigene SwiftUI-View und ist über das TabBar-Menü erreichbar.

// MARK: - MainTabView
struct MainTabView: View {
    @EnvironmentObject var userViewModel: UserViewModel // Benutzer ViewModel über EnvironmentObject
    @EnvironmentObject var quoteViewModel: QuoteViewModel // Quote ViewModel über EnvironmentObject

    var body: some View {
        TabView {
            // MARK: - Home Tab
            HomeView(userViewModel: userViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            // MARK: - Explorer Tab
            ExplorerView(quoteViewModel: quoteViewModel)
                .tabItem {
                    Label("Explorer", systemImage: "magnifyingglass")
                }

            // MARK: - Favorites Tab
            FavoriteView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }

            // MARK: - Galerie Tab
            GalerieScreen()
                .tabItem {
                    Label("Galerie", systemImage: "photo.on.rectangle")
                }

            // MARK: - Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        // MARK: - Aktionen beim Erscheinen der View
        .onAppear {
            // Optionale Aktionen, wenn die TabView erscheint (z.B. Daten aktualisieren)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserViewModel())  // Füge hier das UserViewModel hinzu
        .environmentObject(QuoteViewModel())  // Füge hier das QuoteViewModel hinzu
}
