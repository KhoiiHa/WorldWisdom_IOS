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
            if userViewModel.isLoggedIn {
                HomeView(userViewModel: userViewModel)
                    .environmentObject(userViewModel)
            } else {
                AuthenticationView()
            }
        }
    }
}
