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
        List {
            categoryButton(title: "Alle Kategorien", isSelected: selectedCategory == nil) {
                selectedCategory = nil
            }

            ForEach(Array(categories), id: \.self) { category in
                categoryButton(title: category, isSelected: selectedCategory == category) {
                    selectedCategory = category
                }
            }
        }
        .navigationTitle("Kategorie auswählen")
    }

    private func categoryButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
    }
}

