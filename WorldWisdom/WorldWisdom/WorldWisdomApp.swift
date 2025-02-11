//
//  WorldWisdomApp.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 13.01.25.
//

import SwiftUI
import Firebase
import SwiftData

@main
struct WorldWisdomApp: App {
    
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var quoteViewModel = QuoteViewModel()
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var favoriteManager = FavoriteManager()
    @StateObject private var userQuoteManager = UserQuoteManager()
    
    let container: ModelContainer

    init() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.debug) // Optional für Logging

        do {
            container = try ModelContainer(for: QuoteEntity.self, FireUserEntity.self, FavoriteQuoteEntity.self, UserCreatedQuoteEntity.self)
        } catch {
            fatalError("Fehler beim Erstellen des ModelContainers: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if userViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(userViewModel)
                    .environmentObject(quoteViewModel)
                    .environmentObject(firebaseManager)
                    .environmentObject(favoriteManager)
                    .environmentObject(userQuoteManager)
                    .modelContainer(container)
                    .onAppear {
                        Task {
                            await syncData()
                        }
                    }
            } else {
                AuthenticationView()
                    .modelContainer(container)
                    .onAppear {
                        Task {
                            await syncData()
                        }
                    }
            }
        }
    }

    // Startet die Synchronisation mit Firestore
    private func syncData() async {
        let syncManager = SwiftDataSyncManager(context: container.mainContext)
        await syncManager.syncQuotes()
    }
}
