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
        NavigationStack {
            List {
                Button(action: { selectedCategory = nil }) {
                    HStack {
                        Text("Alle Kategorien")
                        if selectedCategory == nil {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }

                ForEach(Array(categories), id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        HStack {
                            Text(category)
                            if selectedCategory == category {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kategorie auswählen")
        }
    }
}

