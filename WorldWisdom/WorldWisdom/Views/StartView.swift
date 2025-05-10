
//
//  StartView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 10.05.25.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var quoteViewModel: QuoteViewModel
    @State private var navigateToMain = false
    @State private var navigateToRegister = false
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Text("Willkommen bei WorldWisdom")
                    .font(.title)
                    .multilineTextAlignment(.center)

                Text("Entdecke inspirierende Zitate – ohne Registrierung.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                Button("Los geht’s") {
                    Task {
                        await userViewModel.startWithoutAccount()
                        navigateToMain = true
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)

                NavigationLink("Oder registrieren", destination: RegisterView(userViewModel: userViewModel))

                Spacer()

                NavigationLink("Schon ein Konto? Jetzt anmelden", destination: LoginView(userViewModel: userViewModel))
                    .font(.caption)
                    .padding(.bottom)
            }
            .navigationDestination(isPresented: $navigateToMain) {
                MainTabView()
                    .environmentObject(userViewModel)
                    .environmentObject(quoteViewModel)
            }
        }
    }
}

