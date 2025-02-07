//
//  WorldWisdomApp.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 13.01.25.
//

import SwiftUI
import Firebase

@main
struct WorldWisdomApp: App {
    
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var quoteViewModel = QuoteViewModel()
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var favoriteManager = FavoriteManager()
    @StateObject private var userQuoteManager = UserQuoteManager()
    
    init() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.debug) // Optional: Setze das Log-Level
    }
    
    var body: some Scene {
        WindowGroup {
            // Überprüfe, ob der Benutzer eingeloggt ist und zeige MainTabView an
            if userViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(userViewModel)
                    .environmentObject(quoteViewModel)
                    .environmentObject(firebaseManager)
                    .environmentObject(favoriteManager)
                    .environmentObject(userQuoteManager)
                    .onAppear {
                        // Benutzerstatus beim Start überprüfen
                        Task {
                            await userViewModel.checkCurrentUser()
                        }
                    }
            } else {
                AuthenticationView()
                    .onAppear {
                        // Benutzerstatus beim Start überprüfen
                        Task {
                            await userViewModel.checkCurrentUser()
                        }
                    }
            }
        }
    }
}
