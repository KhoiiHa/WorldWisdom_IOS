//
//  RegisterView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import SwiftUI

/// Registrierungsbildschirm für neue Benutzer.
/// Beinhaltet E-Mail- und Passwortfelder, Ladezustand, Fehlermeldungen und Weiterleitung zur MainTabView.

// MARK: - RegisterView
struct RegisterView: View {
    // MARK: - Zustände für Eingaben und Navigation
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var isRegistered: Bool = false  // Neuer Zustand für die Navigation

    @ObservedObject var userViewModel: UserViewModel

    // MARK: - View Body
    var body: some View {
        NavigationStack {
            VStack {
                // Titel
                Text("Registrieren")
                    .font(.largeTitle)
                    .padding()

                // Eingabefeld für die E-Mail
                TextField("E-Mail", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .accessibilityLabel("E-Mail-Eingabefeld")
                    .accessibilityHint("Gib deine E-Mail-Adresse ein")

                // Eingabefeld für das Passwort
                SecureField("Passwort", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("Passwort-Eingabefeld")
                    .accessibilityHint("Gib dein Passwort ein")

                // Registrierungsbutton oder Ladeindikator
                if isLoading {
                    ProgressView() // Ladeindikator
                        .padding(.top, 20)
                } else {
                    Button(action: {
                        Task {
                            isLoading = true // Ladezustand aktivieren
                            await userViewModel.registerUser(email: email, password: password)
                            isLoading = false // Ladezustand deaktivieren
                            
                            // Wenn der Benutzer erfolgreich registriert wurde, zur MainTabView navigieren
                            if userViewModel.isLoggedIn {
                                isRegistered = true
                            }
                        }
                    }) {
                        Text("Registrieren")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("buttonColor"))
                            .foregroundColor(Color("primaryText"))
                            .cornerRadius(10)
                            .accessibilityLabel("Registrierungsbutton")
                            .accessibilityHint("Klicke hier, um dich zu registrieren")
                    }
                    .padding(.top, 20)
                }

                // Anzeige einer Fehlermeldung, falls vorhanden
                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(Color("mainBlue"))
                        .padding(.top, 10)
                        .accessibilityLabel("Fehlermeldung")
                        .accessibilityHint(errorMessage)
                }

                // Zurück zur AuthenticationView Button
                NavigationLink("Zurück zur Anmeldung", destination: AuthenticationView())
                    .foregroundColor(Color("mainBlue"))
                    .padding(.top, 20)

                Spacer()
            }
            .padding()
            .background(Color("background").ignoresSafeArea()) // Hintergrundfarbe aus Asset-Katalog
            .onAppear {
                // Überprüfen, ob der Benutzer bereits angemeldet ist
                Task {
                    await userViewModel.checkCurrentUser()
                }
            }
            .navigationDestination(isPresented: $isRegistered) {
                MainTabView() // Weiterleitung zur MainTabView nach erfolgreicher Registrierung
            }
        }
    }
}

#Preview {
    RegisterView(userViewModel: UserViewModel())
}
