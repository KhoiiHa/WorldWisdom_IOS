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
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
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

            Form {
                Section(header: Text("Benutzeranmeldung")) {
                    TextField("E-Mail", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Passwort", text: $password)
                }

                Section {
                    Button("Registrieren") {
                        guard !email.isEmpty, !password.isEmpty else {
                            viewModel.errorMessage = "Bitte füllen Sie alle Felder aus."
                            return
                        }
                        isLoading = true
                        Task {
                            await viewModel.registerUser(email: email, password: password)
                            isLoading = false
                        }
                    }
                    .disabled(isLoading)

                    Button("Anmelden") {
                        guard !email.isEmpty, !password.isEmpty else {
                            viewModel.errorMessage = "Bitte füllen Sie alle Felder aus."
                            return
                        }
                        isLoading = true
                        Task {
                            await viewModel.loginUser(email: email, password: password)
                            isLoading = false
                        }
                    }
                    .disabled(isLoading)

                    Button("Anonyme Anmeldung") {
                        isLoading = true
                        Task {
                            await viewModel.anonymousLogin()
                            isLoading = false
                        }
                    }
                    .disabled(isLoading)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            if isLoading {
                ProgressView("Wird verarbeitet...")
                    .padding()
            }
        }
        .padding()
        .onAppear {
            viewModel.checkCurrentUser()
        }
        .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
}

#Preview {
    AuthenticationView()
}
