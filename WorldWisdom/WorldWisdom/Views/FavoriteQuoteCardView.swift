//
//  FavoriteQuoteCardView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 05.02.25.
//
import SwiftUI


struct FavoriteQuoteCardView: View {
    @ObservedObject var favoriteManager: FavoriteManager
    let quote: Quote
    @State private var showAuthorDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Zitat Text
            Text("„\(quote.quote)“")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundColor(.primary)
            
            HStack {
                // Autor Name
                Text("- \(quote.author)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
            }
            
            // Button für Dropdown
            Button(action: {
                withAnimation {
                    showAuthorDetails.toggle()
                }
            }) {
                HStack {
                    Text(showAuthorDetails ? "Details ausblenden" : "Mehr über den Autor")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Image(systemName: showAuthorDetails ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
                .padding(.top, 5)
            }

            // Autor-Infos (Dropdown)
            if showAuthorDetails {
                authorInfoCard
                    .transition(.slide)  // Sanfte Animation beim Einblenden
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
    }

    // MARK: - Autor Info Card (Dropdown)
    private var authorInfoCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Über \(quote.author)")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(quote.description)
                .font(.body)
                .foregroundColor(.primary)
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 5))
    }
}
