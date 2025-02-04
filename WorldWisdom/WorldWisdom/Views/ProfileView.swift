//
//  ProfileView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 04.02.25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 🔹 Profilbild mit Rahmen und Zoom-Effekt
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                // Optionaler Zoom-Effekt
                                print("Profilbild getippt!")
                            }
                    }
                    .padding(.top, 20)

                    // 🔹 Benutzername
                    Text("Benutzername")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    // 🔹 Benutzerstatus (optional)
                    Text("Mitglied seit 2023")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // 🔹 Benutzerbeschreibung (optional)
                    Text("Ich liebe inspirierende Zitate und teile sie gerne mit anderen.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Divider()
                        .padding(.vertical, 10)

                    // 🔹 Profil-Einstellungen
                    VStack(spacing: 15) {
                        // Passwort ändern
                        NavigationLink(destination: Text("Passwort ändern")) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.blue)
                                Text("Passwort ändern")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }

                        // Abmelden
                        NavigationLink(destination: Text("Abmelden")) {
                            HStack {
                                Image(systemName: "arrow.right.square.fill")
                                    .foregroundColor(.red)
                                Text("Abmelden")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profil")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

#Preview {
    ProfileView()
}
