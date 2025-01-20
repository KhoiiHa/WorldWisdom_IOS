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
   
    init() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.debug) // Optional: Setze das Log-Level
    }

    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
    }
}
