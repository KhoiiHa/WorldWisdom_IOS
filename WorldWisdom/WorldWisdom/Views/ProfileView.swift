//
//  ProfileView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 04.02.25.
//

import SwiftUI

/// Profilansicht des Nutzers mit Foto, Name, Beschreibung sowie Navigationslinks zu Einstellungen und Logout.
/// Statisches Beispielprofil mit AsyncImage-Handling und einfacher Benutzeroberfläche.

// MARK: - ProfileView
struct ProfileView: View {
    // MARK: - View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Profilbereich
                    VStack(spacing: 12) {
                        // 🔹 Profilbild mit Rahmen und Zoom-Effekt
                        ZStack {
                            Circle()
                                .fill(Color("mainBlue").opacity(0.08))
                                .frame(width: 112, height: 112)
                                .shadow(color: Color("mainBlue").opacity(0.10), radius: 6, y: 2)
                            
                            // Verwende AsyncImage, um das Bild von der URL zu laden
                            AsyncImage(url: URL(string: "https://res.cloudinary.com/dpaehynl2/image/upload/v1740478009/IMG_20221104_215959_602_wguwjt.jpg")) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle()) // Rundes Profilbild
                                        .onTapGesture {
                                            // Optionaler Zoom-Effekt
                                            print("Profilbild getippt!")
                                        }
                                } else if phase.error != nil {
                                    // Fallback-Image, falls ein Fehler auftritt
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(Color("mainBlue"))
                                } else {
                                    // Ladeanzeige, solange das Bild geladen wird
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }

                        // 🔹 Benutzername
                        Text("Benutzername")
                            .font(.title3.bold())
                            .foregroundColor(Color("primaryText"))
                            .multilineTextAlignment(.center)

                        // 🔹 Benutzerstatus (optional)
                        Text("Mitglied seit 2023")
                            .font(.caption)
                            .foregroundColor(Color("secondaryText"))

                        // 🔹 Benutzerbeschreibung (optional)
                        Text("Ich liebe inspirierende Zitate und teile sie gerne mit anderen.")
                            .font(.subheadline)
                            .foregroundColor(Color("secondaryText"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                    .padding(.vertical, 18)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThinMaterial)
                            .shadow(color: Color("primaryText").opacity(0.04), radius: 8, y: 2)
                    )

                    Divider()
                        .padding(.vertical, 10)

                    // MARK: - Profil-Einstellungen
                    VStack(spacing: 15) {
                        // Passwort ändern
                        NavigationLink(destination: Text("Passwort ändern")) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color("mainBlue"))
                                Text("Passwort ändern")
                                    .foregroundColor(Color("primaryText"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("secondaryText"))
                            }
                            .padding(12)
                            .background(Color("cardBackground"))
                            .cornerRadius(10)
                        }

                        // Abmelden
                        NavigationLink(destination: Text("Abmelden")) {
                            HStack {
                                Image(systemName: "arrow.right.square.fill")
                                    .foregroundColor(Color("mainBlue"))
                                Text("Abmelden")
                                    .foregroundColor(Color("primaryText"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("secondaryText"))
                            }
                            .padding(12)
                            .background(Color("mainBlue").opacity(0.09))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Profil")
            .background(Color("background").ignoresSafeArea())
        }
    }
}

#Preview {
    ProfileView()
}
