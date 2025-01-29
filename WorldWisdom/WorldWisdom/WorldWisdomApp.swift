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
    
    init() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.debug) // Optional: Setze das Log-Level
    }
    
    var body: some Scene {
        WindowGroup {
            // Überprüfe, ob der Benutzer eingeloggt ist und zeige MainTabView an
            if userViewModel.isLoggedIn {
                MainTabView() // Zeigt MainTabView an, wenn der Nutzer eingeloggt ist
                    .environmentObject(userViewModel) // Übergibt das userViewModel an die MainTabView
                    .onAppear {
                        // Benutzerstatus beim Start überprüfen
                        Task {
                            await userViewModel.checkCurrentUser()
                        }
                    }
            } else {
                AuthenticationView() // Zeigt die AuthenticationView an, wenn der Nutzer nicht eingeloggt ist
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
