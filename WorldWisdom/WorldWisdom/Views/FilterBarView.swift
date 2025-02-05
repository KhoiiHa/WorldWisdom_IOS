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
            HStack {
                Button(action: { selectedCategory = nil }) {
                    Text("Alle")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == nil ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedCategory == nil ? Color.blue : Color.gray, lineWidth: 1)
                        )
                }

                ForEach(categories, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedCategory == category ? Color.blue : Color.gray, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

