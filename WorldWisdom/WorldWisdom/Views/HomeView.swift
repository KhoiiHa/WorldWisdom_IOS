//
//  HomeView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import SwiftUI

struct HomeView: View {
    // Bindung zur Instanz von UserViewModel
    @ObservedObject var userViewModel: UserViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Text("Willkommen zur HomeView!")
                    .font(.largeTitle)
                    .padding()

                if let email = userViewModel.user?.email {
                    Text("Angemeldeter Benutzer: \(email)")
                        .padding()
                        .foregroundColor(.green)
                } else {
                    Text("Kein Benutzer angemeldet")
                        .padding()
                        .foregroundColor(.red)
                }

                Spacer()

                // Abmelden-Button
                Button("Abmelden") {
                    Task {
                        await userViewModel.signOut() 
                        print("Benutzer abgemeldet")
                    }
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
}

#Preview {
    HomeView(userViewModel: UserViewModel())
}
