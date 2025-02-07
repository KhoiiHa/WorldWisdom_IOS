//
//  FavoriteQuoteCardView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//
import SwiftUI

struct FavoriteQuoteCardView: View {
    let quote: Quote
    let unfavoriteAction: () async throws -> Void  // Die Action kann jetzt Fehler werfen

    @State private var showErrorMessage: Bool = false  // Fehleranzeige für diese View
    @State private var isRemoving: Bool = false  // Um zu erkennen, ob der Entfernen-Prozess läuft

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(quote.quote)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)  // Begrenzung der Zeilenanzahl
                .padding(.bottom, 5)

            Text("- \(quote.author)")
                .font(.caption)
                .foregroundColor(.gray)

            if showErrorMessage {
                Text("Fehler beim Entfernen des Favoriten. Bitte versuchen Sie es später erneut.")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.05)]), startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)  // Sanfter Schatten
        .overlay(alignment: .topTrailing) {
            Button(action: {
                Task {
                    await unfavoriteQuote()
                }
            }) {
                Image(systemName: "heart.slash")
                    .foregroundColor(isRemoving ? .gray : .red) // Buttonfarbe ändern während des Entfernens
                    .padding(12)
                    .background(Color.white.opacity(0.7))  // Halbtransparente Hintergrundfarbe für den Button
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 2, y: 2)  // Kleiner Schatten für den Button
                    .overlay(Circle().stroke(Color.red, lineWidth: 1))  // Rote Umrandung für den Button
                    .padding(10)
                    .disabled(isRemoving)  // Button während der Entfernung deaktivieren
            }
            .buttonStyle(PlainButtonStyle())  // Deaktiviert die Standard-Button-Stile
        }
    }

    // Fehlerbehandlung für unfavoriteAction
    private func unfavoriteQuote() async {
        isRemoving = true  // Button während des Entfernens deaktivieren
        do {
            try await unfavoriteAction() // Wir rufen einfach die unfavoriteAction auf
            showErrorMessage = false  // Fehleranzeige zurücksetzen
        } catch {
            showErrorMessage = true  // Fehleranzeige aktivieren
            print("Fehler beim Entfernen des Favoriten: \(error.localizedDescription)")
        }
        isRemoving = false  // Entfernen-Prozess abgeschlossen, Button wieder aktiv
    }
}


