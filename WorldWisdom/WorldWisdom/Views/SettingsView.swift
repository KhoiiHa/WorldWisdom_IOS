//
//  SettingsView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 24.01.25.
//

import SwiftUI

/// Einstellungsansicht mit moderner Card-Optik, Akzentfarben und aufgeräumten Abschnitten.

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @Environment(\.presentationMode) var presentationMode
    @State private var shouldNavigateToStart = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Dezenter, systemkonformer Hintergrund
                Color("background").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 32) {
                        if !networkMonitor.isConnected {
                            Text("⚠️ Offline-Modus – Änderungen werden ggf. nicht synchronisiert")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }
                        // MARK: - Konto & Benachrichtigungen
                        SettingsSection(title: "Konto & Benachrichtigungen") {
                            NavigationLink(destination: ProfileView().environmentObject(networkMonitor)) {
                                SettingsRow(iconName: "person.circle", label: "Profil", color: .blue)
                            }
                            Divider()
                            NavigationLink(destination: Text("Benachrichtigungseinstellungen")) {
                                SettingsRow(iconName: "bell", label: "Benachrichtigungen", color: .orange)
                            }
                        }
                        // MARK: - App-Infos
                        SettingsSection(title: "App") {
                            NavigationLink(destination: Text("Datenschutzrichtlinien")) {
                                SettingsRow(iconName: "lock.shield", label: "Datenschutz", color: .green)
                            }
                            Divider()
                            NavigationLink(destination: InfoView()) {
                                SettingsRow(iconName: "info.circle", label: "Über die App", color: .purple)
                            }
                            Divider()
                            HStack {
                                SettingsRow(iconName: "moon.fill", label: "Dark Mode", color: .gray)
                                Spacer()
                                Toggle("", isOn: $isDarkMode)
                                    .labelsHidden()
                            }
                            .padding(.trailing, 12)
                        }
                        // MARK: - Logout-Button als Eye-Catcher
                        Button(action: logout) {
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.right.square")
                                    .font(.system(size: 22))
                                Text("Abmelden")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .foregroundColor(Color("primaryText"))
                            .padding()
                            .background(
                                Color("mainBlue").opacity(0.93)
                            )
                            .cornerRadius(14)
                            .shadow(color: Color("mainBlue").opacity(0.18), radius: 6, y: 2)
                        }
                        .padding(.top, 6)
                        // MARK: - Version Card
                        VersionCard()
                    }
                    .padding(.vertical, 36)
                    .padding(.horizontal, 12)
                    .animation(.spring(), value: shouldNavigateToStart)
                }
            }
            .navigationTitle("Einstellungen")
            .navigationDestination(isPresented: $shouldNavigateToStart) {
                StartView()
                    .environmentObject(firebaseManager)
                    .environmentObject(networkMonitor)
            }
        }
    }

    private func logout() {
        do {
            try firebaseManager.signOut()
            shouldNavigateToStart = true
        } catch {
            print("Fehler beim Abmelden: \(error.localizedDescription)")
        }
    }
}

// MARK: - Einstellungen-Sektion
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.footnote)
                .foregroundColor(Color("mainBlue"))
                .padding(.leading, 12)
                .padding(.bottom, 2)
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("cardBackground"))
                    .shadow(color: Color("primaryText").opacity(0.04), radius: 3, y: 1)
            )
        }
    }
}

// MARK: - Einstellungszeile mit Icon und Label
struct SettingsRow: View {
    let iconName: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.13))
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(color)
            }
            Text(label)
                .foregroundColor(Color("primaryText"))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("secondaryText").opacity(0.36))
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}

// MARK: - App-Version Anzeige
struct VersionCard: View {
    var body: some View {
        HStack {
            Image(systemName: "gearshape")
                .foregroundColor(Color("secondaryText"))
            Text("Version")
                .foregroundColor(Color("secondaryText"))
            Spacer()
            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                .foregroundColor(Color("secondaryText"))
        }
        .font(.footnote)
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("cardBackground"))
        )
    }
}

#Preview {
    SettingsView()
}
