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
    
    @EnvironmentObject var viewModel: QuoteViewModel // Das ViewModel als EnvironmentObject
    
    var quoteToEdit: Quote? // Optionales Zitat zum Bearbeiten

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
                .disabled(quoteText.isEmpty)
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
                    // Aktualisieren des Zitats
                    try await FirebaseManager.shared.updateQuote(quoteToEdit)
                } else {
                    // Neues Zitat speichern
                    try await FirebaseManager.shared.saveUserQuote(quoteText: quoteText, author: author)
                }

                // Benachrichtige das ViewModel, dass sich die Daten geändert haben
                try await viewModel.loadFavoriteQuotes() // Erneutes Laden der Favoriten
                dismiss()
            } catch {
                errorMessage = "Fehler: \(error.localizedDescription)"
            }
            isSaving = false
        }
    }
}

#Preview {
    AddQuoteView(quoteToEdit: nil) // Zeigt die Ansicht ohne Zitat zum Bearbeiten
}
