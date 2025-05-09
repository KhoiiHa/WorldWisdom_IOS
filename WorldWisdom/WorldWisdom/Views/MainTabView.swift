//
//  MainTabView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 29.01.25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userViewModel: UserViewModel // Benutzer ViewModel über EnvironmentObject
    @EnvironmentObject var quoteViewModel: QuoteViewModel // Quote ViewModel über EnvironmentObject

    var body: some View {
        TabView {
            // Home Tab
            HomeView(userViewModel: userViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            // Explorer Tab
            ExplorerView(quoteViewModel: quoteViewModel)
                .tabItem {
                    Label("Explorer", systemImage: "magnifyingglass")
                }

            // Favorites Tab
            FavoriteView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }

            // Galerie Tab
            GalerieScreen()
                .tabItem {
                    Label("Galerie", systemImage: "photo.on.rectangle")
                }

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
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
