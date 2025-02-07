//
//  AddQuoteView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//

import SwiftUI

struct AddQuoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var quoteText = ""
    @State private var author = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    @EnvironmentObject var userQuoteManager: UserQuoteManager // Benutzerspezifische Zitate

    var quoteToEdit: Quote? // Optional: Zitat zum Bearbeiten

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Gib dein Zitat ein...", text: $quoteText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Autor (optional)", text: $author)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: saveQuote) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text(quoteToEdit == nil ? "Zitat speichern" : "Zitat aktualisieren")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(quoteText.isEmpty || isSaving)
                .padding()
            }
            .padding()
            .navigationTitle(quoteToEdit == nil ? "Eigenes Zitat" : "Zitat bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
        .onAppear {
            if let quoteToEdit = quoteToEdit {
                quoteText = quoteToEdit.quote
                author = quoteToEdit.author
                print("Zitat zum Bearbeiten geladen: \(quoteText), \(author)") // Debug
            }
        }
    }

    // 🛠️ Speichert oder aktualisiert das Zitat
    private func saveQuote() {
        isSaving = true
        errorMessage = nil

        Task {
            do {
                if let quoteToEdit = quoteToEdit {
                    // Zitat aktualisieren
                    print("Aktualisiere Zitat: \(quoteText), \(author)")
                    try await FirebaseManager.shared.updateUserQuote(id: quoteToEdit.id, newText: quoteText, newAuthor: author)
                } else {
                    // Neues Zitat speichern
                    print("Speichere neues Zitat: \(quoteText), \(author)")
                    await userQuoteManager.addUserQuote(quoteText: quoteText, author: author)
                }

                dismiss() // Schließt die Ansicht nach erfolgreichem Speichern
            } catch {
                errorMessage = "Fehler: \(error.localizedDescription)"
                print("Fehler: \(error.localizedDescription)") // Fehlerlog
            }
            isSaving = false
        }
    }
}

#Preview {
    AddQuoteView(quoteToEdit: nil)
        .environmentObject(UserQuoteManager()) // Vorschau mit EnvironmentObject
}
