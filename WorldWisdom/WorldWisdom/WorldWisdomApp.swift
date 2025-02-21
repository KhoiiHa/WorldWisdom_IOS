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
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var favoriteManager = FavoriteManager()
    @StateObject private var userQuoteManager = UserQuoteManager()
    
    @StateObject private var quoteViewModel = QuoteViewModel() // Direkte Initialisierung
    let container: ModelContainer

    init() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.debug) // Optional für Logging
        
        do {
            // Initialisiere den ModelContainer für alle Modelle
            container = try ModelContainer(for: QuoteEntity.self, FireUserEntity.self, FavoriteQuoteEntity.self)
        } catch {
            fatalError("Fehler beim Erstellen des ModelContainers: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            // Überprüfe, ob der User eingeloggt ist und zeige das entsprechende View
            if userViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(userViewModel)
                    .environmentObject(quoteViewModel) // Weitergabe des quoteViewModel für die Galerie und andere Views
                    .environmentObject(firebaseManager)
                    .environmentObject(favoriteManager)
                    .environmentObject(userQuoteManager)
                    .modelContainer(container)
                    .onAppear {
                        // Synchronisiere Daten nach dem Laden der App
                        Task {
                            await syncData()
                        }
                    }
            } else {
                AuthenticationView()
                    .modelContainer(container)
                    .onAppear {
                        // Synchronisiere Daten nach dem Laden der App
                        Task {
                            await syncData()
                        }
                    }
            }
        }
    }

    // Startet die Synchronisation mit Firestore
    private func syncData() async {
        let syncManager = SwiftDataSyncManager()
        await syncManager.syncQuotesFromFirestore()  // Hol die Zitate aus Firebase und speichere sie in SwiftData
    }
}
