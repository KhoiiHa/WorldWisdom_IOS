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
    @AppStorage("isDarkMode") private var isDarkMode = true
    @EnvironmentObject var userViewModel: UserViewModel // Benutzer ViewModel über EnvironmentObject
    @EnvironmentObject var quoteViewModel: QuoteViewModel // Quote ViewModel über EnvironmentObject

    var body: some View {
        TabView {
            // MARK: - Startseite
            // Startseite/Home Tab
            HomeView(userViewModel: userViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.circle.fill")
                }

            // MARK: - Entdecken
            // Explorer Tab
            ExplorerView(quoteViewModel: quoteViewModel)
                .tabItem {
                    Label("Explorer", systemImage: "sparkle.magnifyingglass")
                }

            // MARK: - Favoriten
            // Favoriten Tab
            FavoriteView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.circle.fill")
                }

            // MARK: - Galerie
            // Galerie Tab
            GalerieScreen()
                .tabItem {
                    Label("Galerie", systemImage: "photo.fill.on.rectangle.fill")
                }

            // MARK: - Einstellungen
            // Einstellungen/Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear.circle.fill")
                }
        }
        // MARK: - Hintergrundfarbe aus Asset-Katalog
        .background(Color("background").ignoresSafeArea())
        // MARK: - Akzentfarbe aus Asset-Katalog
        .accentColor(Color("mainBlue"))
        .colorScheme(isDarkMode ? .dark : .light)
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
