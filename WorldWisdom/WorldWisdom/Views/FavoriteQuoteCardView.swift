//
//  FavoriteQuoteCardView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//
import SwiftUI

struct FavoriteQuoteCardView: View {
    let quote: Quote
    let unfavoriteAction: () async throws -> Void  // Action, die Fehler werfen kann

    @State private var showErrorMessage: Bool = false  // Anzeige der Fehlermeldung
    @State private var isRemoving: Bool = false  // Wird gesetzt, wenn das Entfernen läuft

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Zitat anzeigen
            Text("„\(quote.quote)“")
                .font(.body)
                .italic()
                .foregroundColor(.primary)
                .lineLimit(3)  // Maximale Zeilenanzahl für das Zitat
                .padding(.bottom, 5)

            // Autor des Zitats
            Text("- \(quote.author)")
                .font(.caption)
                .foregroundColor(.secondary)

            // Fehleranzeige (falls nötig)
            if showErrorMessage {
                Text("Fehler beim Entfernen des Favoriten. Bitte versuchen Sie es später erneut.")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))  // Abrundung des Cards
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)  // Schattierung für den Card
    }

    // Swipe-to-Delete-Logik
    private func unfavoriteQuote() async {
        isRemoving = true  // Deaktiviert den Button während des Entfernens
        do {
            try await unfavoriteAction()  // Führe die unfavoriteAction aus
            showErrorMessage = false  // Fehleranzeige zurücksetzen, falls erfolgreich
        } catch {
            showErrorMessage = true  // Fehleranzeige aktivieren, falls ein Fehler auftritt
            print("Fehler beim Entfernen des Favoriten: \(error.localizedDescription)")
        }
        isRemoving = false  // Entfernen abgeschlossen, Button wieder aktiv
    }
}
