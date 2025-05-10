//
//  CategoryFilterView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//

import SwiftUI

struct CategoryFilterView: View {
    let categories: Set<String>
    @Binding var selectedCategory: String?

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
            .contentShape(Rectangle()) // Tappbare Fläche erweitern
        }
        .listRowBackground(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
    }
}
