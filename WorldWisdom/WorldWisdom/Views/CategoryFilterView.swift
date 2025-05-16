//
//  CategoryFilterView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//
//  Diese View zeigt eine Liste von Kategorien, aus denen der Nutzer eine auswählen kann,
//  um Inhalte zu filtern. Die Auswahl kann auf eine einzelne Kategorie oder auf alle Kategorien gesetzt werden.
//  Diese Komponente eignet sich für Filterfunktionen in Apps mit kategorisierten Inhalten.

import SwiftUI


/// Zeigt eine Liste verfügbarer Kategorien als auswählbare Buttons.
/// Der Nutzer kann eine Kategorie filtern oder "Alle Kategorien" wählen.
struct CategoryFilterView: View {
    let categories: Set<String>
    @Binding var selectedCategory: String?

    // MARK: - View Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                categoryButton(title: "Alle Kategorien", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(categories.sorted(), id: \.self) { category in
                    categoryButton(title: category, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Kategorie auswählen")
        // Hintergrundfarbe aus Asset-Katalog verwenden
        .background(Color("background").ignoresSafeArea())
    }

    // MARK: - Hilfsfunktion für Kategorie-Buttons
    /// Baut einen Button für eine einzelne Kategorie.
    private func categoryButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(Color("primaryText"))
                    .fontWeight(isSelected ? .semibold : .regular)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("mainBlue"))
                        .transition(.scale)
                }
            }
            .padding()
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color("mainBlue").opacity(0.15) : Color("cardBackground"))
                    .shadow(color: Color("buttonColor").opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("mainBlue") : .clear, lineWidth: 1)
            )
            .padding(.horizontal)
            .accessibilityLabel(Text(isSelected ? "\(title), ausgewählt" : title))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
