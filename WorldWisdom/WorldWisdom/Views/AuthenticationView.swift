//
//  AuthenticationView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 16.01.25.
//

import SwiftUI

// Diese View verwaltet die Benutzeranmeldung und Navigation zur Hauptansicht.
struct AuthenticationView: View {
    @StateObject private var viewModel = UserViewModel()

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var navigateToHome: Bool = false // Um die Navigation dynamisch zu steuern

    var body: some View {
        NavigationStack {
            VStack {
                if let user = viewModel.user {
                    Text("Angemeldeter Benutzer: \(user.email ?? "Unbekannt")")
                        .foregroundColor(Color("mainBlue"))
                        .padding()
                    Text("UID: \(user.uid)")
                        .padding()

                    // Direkt zur HomeView navigieren, wenn der Benutzer erfolgreich eingeloggt ist
                    EmptyView()
                } else {
                    Text("Bitte melden Sie sich an oder registrieren Sie sich.")
                        .padding()
                }

                // MARK: - Anmeldeformular
                Form {
                    Section(header: Text("Benutzeranmeldung")) {
                        TextField("E-Mail", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        SecureField("Passwort", text: $password)
                    }

                    // MARK: - Aktionen: Registrierung und Anmeldung
                    Section {
                        NavigationLink(destination: RegisterView(userViewModel: viewModel)) {
                            Text("Jetzt registrieren")
                                .foregroundColor(Color("mainBlue"))
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
                                if viewModel.user != nil {
                                    navigateToHome = true // Nach erfolgreichem Login zur HomeView navigieren
                                }
                            }
                        }
                        .disabled(isLoading)

                        Button("Anonyme Anmeldung") {
                            isLoading = true
                            Task {
                                await viewModel.anonymousLogin()
                                isLoading = false
                                if viewModel.user != nil {
                                    navigateToHome = true // Nach erfolgreicher anonymer Anmeldung zur HomeView navigieren
                                }
                            }
                        }
                        .disabled(isLoading)
                    }
                }

                // MARK: - Fehleranzeige
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(Color("mainBlue"))
                        .padding()
                }

                // MARK: - Ladeanzeige
                if isLoading {
                    ProgressView("Wird verarbeitet...")
                        .padding()
                }
            }
            .padding()
            .background(Color("background").ignoresSafeArea()) // Hintergrundfarbe zur Unterstützung des Dunkelmodus
            .onAppear {
                Task {
                    await viewModel.checkCurrentUser()
                    email = ""
                    password = ""
                    viewModel.errorMessage = nil
                    navigateToHome = false
                }
            }
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
            .navigationDestination(isPresented: $navigateToHome) {
                MainTabView()
                    .environmentObject(viewModel)
                    .environmentObject(QuoteViewModel())
                    .environmentObject(FirebaseManager.shared)
                    .environmentObject(FavoriteManager.shared)
            }
        }
        .preferredColorScheme(.none) // Unterstützt automatisch den Hell- und Dunkelmodus
    }
}

#Preview {
    AuthenticationView()
}
