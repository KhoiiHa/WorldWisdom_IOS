//
//  SettingsView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.presentationMode) var presentationMode  // Zum Schließen der View nach dem Abmelden

    var body: some View {
        NavigationStack {
            List {
                // 🔹 Sektion: Benutzereinstellungen
                Section(header: Text("Benutzereinstellungen")) {
                    NavigationLink(destination: ProfileView()) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.blue)
                            Text("Profil")
                        }
                    }
                    
                    NavigationLink(destination: Text("Benachrichtigungseinstellungen")) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.blue)
                            Text("Benachrichtigungen")
                        }
                    }
                }
                
                // 🔹 Sektion: App-Informationen
                Section(header: Text("App-Informationen")) {
                    NavigationLink(destination: Text("Datenschutzrichtlinien")) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.green)
                            Text("Datenschutz")
                        }
                    }
                    
                    NavigationLink(destination: Text("Über die App")) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.green)
                            Text("Über die App")
                        }
                    }
                }
                
                // 🔹 Sektion: Aktionen
                Section {
                    Button(action: {
                        logout()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                            Text("Abmelden")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Einstellungen")
        }
    }

    private func logout() {
        do {
            try firebaseManager.signOut() // Abmelden durch FirebaseManager
            print("Erfolgreich abgemeldet")

            // Optional: Zurück zum Login-Screen
            presentationMode.wrappedValue.dismiss() // Schließt die aktuelle View

        } catch {
            print("Fehler beim Abmelden: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}
