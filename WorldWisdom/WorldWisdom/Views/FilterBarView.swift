//
//  FilterBarView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//

import SwiftUI

/// Header-Komponente für verschiedene Screens – zeigt optional einen Begrüßungstext und App-Titel.

/// Zeigt eine horizontale Leiste mit Kategorie-Buttons zur Filterung von Zitaten.
/// Unterstützt die Auswahl einzelner Kategorien sowie eine "Alle"-Option.

// MARK: - FilterBar
struct FilterBar: View {
    @Binding var selectedCategory: String?
    let categories: [String]
    
    // MARK: - View Body
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
            .background(Color("background").ignoresSafeArea()) // Hintergrundfarbe aus Asset-Katalog
        }
    }
    
    // MARK: - Hilfsfunktion für Kategorie-Buttons
    /// Erzeugt einen Button für eine Kategorie mit entsprechendem Stil
    private func categoryButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? Color("mainBlue").opacity(0.2) // Akzentfarbe mit Transparenz bei Auswahl
                        : Color("cardBackground") // Kartenhintergrundfarbe sonst
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color("mainBlue") : Color("secondaryText").opacity(0.4), lineWidth: 1) // Rahmenfarbe
                )
                .foregroundColor(isSelected ? Color("mainBlue") : Color("primaryText")) // Textfarbe anpassen
        }
        .buttonStyle(PlainButtonStyle())
    }
}
