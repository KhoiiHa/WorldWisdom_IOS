//
//  InfoView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 13.05.25.
//



import SwiftUI

// Zeigt eine Übersicht über die App, ihre Funktion und den Entwickler.
struct InfoView: View {
    @AppStorage("didSeeInfo") private var didSeeInfo = false
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 10) {
                        Image(systemName: "book.fill")
                            .foregroundColor(.accentColor)
                        Text("Über WorldWisdom")
                    }
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                    Text("WorldWisdom ist eine Zitat-App, die inspirierende Gedanken von großen Denkern, Autor:innen und Persönlichkeiten aus aller Welt sammelt. Die App hilft dir, tägliche Motivation zu finden, neue Perspektiven zu entdecken und deine Lieblingszitate als Favoriten zu speichern.")
                        .font(.body)
                        .lineSpacing(4)

                    Divider()

                    HStack(spacing: 10) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.accentColor)
                        Text("Über den Entwickler")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)

                    Text("Diese App wurde von Minh Khoi Ha entwickelt – als persönliches iOS-Projekt, um SwiftUI, Firebase und SwiftData in einem realistischen Szenario einzusetzen. Ziel war es, ein funktionales, inspirierendes und technisch sauberes Portfolio-Projekt zu erstellen.")
                        .font(.body)
                        .lineSpacing(4)

                    Divider()

                    HStack(spacing: 10) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .foregroundColor(.accentColor)
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

                    Button(action: {
                        didSeeInfo = true
                    }) {
                        Text("Jetzt loslegen")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 4)
                )
                .padding()
            }
        }
        .navigationTitle("Über die App")
    }
}
