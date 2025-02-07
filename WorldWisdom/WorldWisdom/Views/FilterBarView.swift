//
//  FilterBarView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//

import SwiftUI

struct FilterBar: View {
    @Binding var selectedCategory: String?
    let categories: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "Alle"-Button
                categoryButton(title: "Alle", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                
                // Kategorie-Buttons
                ForEach(categories, id: \.self) { category in
                    categoryButton(title: category, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Hilfsfunktion für Kategorie-Buttons
    private func categoryButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.accentColor.opacity(0.2) : Color.clear
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.gray, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
