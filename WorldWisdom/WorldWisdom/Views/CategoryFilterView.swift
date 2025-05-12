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
    }

    // MARK: - Hilfsfunktion für Kategorie-Buttons
    private func categoryButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .contentShape(Rectangle())
        }
        .listRowBackground(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .buttonStyle(.plain)
        .accessibilityLabel(Text(isSelected ? "\(title), ausgewählt" : title))
    }
}
