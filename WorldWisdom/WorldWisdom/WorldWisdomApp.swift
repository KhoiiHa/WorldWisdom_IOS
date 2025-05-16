//
//  WorldWisdomApp.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 13.01.25.
//

import SwiftUI
import Firebase
import SwiftData

/// Einstiegspunkt der App – initialisiert Firebase, SwiftData und stellt ViewModels global bereit.

// MARK: - WorldWisdomApp
@main
struct WorldWisdomApp: App {
    
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var favoriteManager = FavoriteManager.shared
    
    @StateObject private var quoteViewModel = QuoteViewModel()
    let container: ModelContainer
    @AppStorage("didSeeInfo") private var didSeeInfo = false

    // MARK: - Initialisierung von Firebase & SwiftData
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
    
    // MARK: - Szenenaufbau (Loginprüfung & View-Weiche)
    var body: some Scene {
        WindowGroup {
            if !didSeeInfo {
                NavigationStack {
                    InfoView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Weiter") {
                                    didSeeInfo = true
                                }
                            }
                        }
                }
                .preferredColorScheme(.dark)
            } else {
                if userViewModel.isLoggedIn {
                    NavigationStack {
                        MainTabView()
                            .preferredColorScheme(.dark)
                    }
                    .environmentObject(userViewModel)
                    .environmentObject(quoteViewModel)
                    .environmentObject(firebaseManager)
                    .environmentObject(favoriteManager)
                    .modelContainer(container)
                    .onAppear {
                        // Synchronisiere Daten nur nach erfolgreicher Anmeldung
                        Task {
                            await syncData()
                        }
                    }
                } else {
                    StartView()
                        .preferredColorScheme(.dark)
                        .environmentObject(userViewModel)
                        .environmentObject(quoteViewModel)
                        .environmentObject(firebaseManager)
                        .environmentObject(favoriteManager)
                        .modelContainer(container)
                }
            }
        }
    }

    // MARK: - Datensynchronisation
    // Startet die Synchronisation mit Firestore
    private func syncData() async {
        if userViewModel.isLoggedIn {
            let syncManager = SwiftDataSyncManager()
            await syncManager.syncQuotesFromFirestore()  // Hol die Zitate aus Firebase und speichere sie in SwiftData
        }
    }
}

