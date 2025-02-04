//
//  SettingsView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

struct SettingsView: View {
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
                        // Logout-Logik hier einfügen
                        print("Benutzer ausgeloggt")
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
}

#Preview {
    SettingsView()
}
