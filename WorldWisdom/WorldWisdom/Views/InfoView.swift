//
//  InfoView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 13.05.25.
//



import SwiftUI

// MARK: - InfoView
// Zeigt eine Übersicht über die App, ihre Funktion und den Entwickler.
struct InfoView: View {
    @AppStorage("didSeeInfo") private var didSeeInfo = false
    
    var body: some View {
        ScrollView {
            VStack {
                // MARK: - Hauptinhalt
                VStack(alignment: .leading, spacing: 22) {
                    // MARK: Über WorldWisdom
                    HStack(spacing: 10) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color("mainBlue"))
                            .background(
                                Circle().fill(Color("mainBlue").opacity(0.10))
                                    .frame(width: 44, height: 44)
                            )
                        Text("Über WorldWisdom")
                    }
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                    Text("WorldWisdom ist eine Zitat-App, die inspirierende Gedanken von großen Denkern, Autor:innen und Persönlichkeiten aus aller Welt sammelt. Die App hilft dir, tägliche Motivation zu finden, neue Perspektiven zu entdecken und deine Lieblingszitate als Favoriten zu speichern.")
                        .font(.body)
                        .lineSpacing(4)

                    Divider()
                        .padding(.vertical, 6)

                    // MARK: Über den Entwickler
                    HStack(spacing: 10) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color("mainBlue"))
                            .background(
                                Circle().fill(Color("mainBlue").opacity(0.10))
                                    .frame(width: 44, height: 44)
                            )
                        Text("Über den Entwickler")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)

                    Text("Diese App wurde von Minh Khoi Ha entwickelt – als persönliches iOS-Projekt, um SwiftUI, Firebase und SwiftData in einem realistischen Szenario einzusetzen. Ziel war es, ein funktionales, inspirierendes und technisch sauberes Portfolio-Projekt zu erstellen.")
                        .font(.body)
                        .lineSpacing(4)

                    Divider()
                        .padding(.vertical, 6)

                    // MARK: Technologien
                    HStack(spacing: 10) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color("mainBlue"))
                            .background(
                                Circle().fill(Color("mainBlue").opacity(0.10))
                                    .frame(width: 44, height: 44)
                            )
                        Text("Technologien")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("• SwiftUI – Benutzeroberfläche")
                        Text("• Firebase – Authentifizierung & Cloud-Datenbank")
                        Text("• SwiftData – Lokale Datenspeicherung & Offline-Modus")
                        Text("• MVVM – Architekturstruktur")
                        Text("• Cloudinary – Autorenbilder")
                    }
                    .lineSpacing(4)

                    // MARK: Button zum Bestätigen
                    Button(action: {
                        didSeeInfo = true
                    }) {
                        Text("Jetzt loslegen")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("mainBlue"))
                            .foregroundColor(Color("primaryText"))
                            .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)

                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color("secondaryText").opacity(0.16), radius: 10, x: 0, y: 4)
                )
                .padding(.vertical, 36)
                .padding(.horizontal, 12)
            }
        }
        .background(Color("background").ignoresSafeArea())
        .navigationTitle("Über die App")
    }
}
