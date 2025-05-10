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
    @StateObject private var favoriteManager = FavoriteManager.shared
    @StateObject private var userQuoteManager = UserQuoteManager.shared
    
    @StateObject private var quoteViewModel = QuoteViewModel()
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
                NavigationStack {
                    MainTabView()
                }
                .environmentObject(userViewModel)
                .environmentObject(quoteViewModel)
                .environmentObject(firebaseManager)
                .environmentObject(favoriteManager)
                .environmentObject(userQuoteManager)
                .modelContainer(container)
                .onAppear {
                    // Synchronisiere Daten nur nach erfolgreicher Anmeldung
                    Task {
                        await syncData()
                    }
                }
            } else {
                StartView()
                    .environmentObject(userViewModel)
                    .environmentObject(quoteViewModel)
                    .environmentObject(firebaseManager)
                    .environmentObject(favoriteManager)
                    .environmentObject(userQuoteManager)
                    .modelContainer(container)
            }
        }
    }

    // Startet die Synchronisation mit Firestore
    private func syncData() async {
        if userViewModel.isLoggedIn {
            let syncManager = SwiftDataSyncManager()
            await syncManager.syncQuotesFromFirestore()  // Hol die Zitate aus Firebase und speichere sie in SwiftData
        }
    }
}
