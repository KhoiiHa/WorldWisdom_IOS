//
//  HomeView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var isLoggedOut = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Willkommen zur HomeView!")
                    .font(.largeTitle)
                    .padding()
                if let user = userViewModel.user {
                    if let email = user.email {
                        Text("Angemeldeter Benutzer: \(email)")
                            .padding()
                            .foregroundColor(.green)
                    } else {
                        Text("Anonym angemeldet. UID: \(user.uid)")
                            .padding()
                            .foregroundColor(.blue)
                    }
                }
                Spacer()

                // Abmelden-Button
                Button("Abmelden") {
                    Task {
                        await userViewModel.signOut()
                        isLoggedOut = true
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
            .navigationDestination(isPresented: $isLoggedOut) {
                AuthenticationView()
            }
        }
    }
}

#Preview {
    HomeView(userViewModel: UserViewModel())
}
