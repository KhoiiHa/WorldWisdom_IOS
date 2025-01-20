//
//  AuthenticationView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 16.01.25.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = UserViewModel()

    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack {
            // Benutzerinformationen anzeigen
            if let user = viewModel.user {
                Text("Angemeldeter Benutzer: \(user.email ?? "Unbekannt")")
                    .foregroundColor(.green)
                    .padding()
                Text("UID: \(user.uid)")
                    .padding()
            } else {
                Text("Bitte melden Sie sich an oder registrieren Sie sich.")
                    .padding()
            }

            // Eingabefelder und Buttons wie zuvor
            TextField("E-Mail", text: $email)
                .padding()
                .keyboardType(.emailAddress)

            SecureField("Passwort", text: $password)
                .padding()

            HStack {
                Button("Registrieren") {
                    Task {
                        await viewModel.registerUser(email: email, password: password)
                    }
                }
                .padding()

                Button("Anmelden") {
                    Task {
                        await viewModel.loginUser(email: email, password: password)
                    }
                }
                .padding()

                Button("Anonyme Anmeldung") {
                    Task {
                        await viewModel.anonymousLogin()
                    }
                }
                .padding()
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            viewModel.checkCurrentUser() // Prüft beim Start, ob der Benutzer eingeloggt ist
        }
    }
}
#Preview {
    AuthenticationView()
}
