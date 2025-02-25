//
//  LoginView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 21.01.25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var isLoggedIn: Bool = false  // Neuer Zustand für die Navigation

    @ObservedObject var userViewModel: UserViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Text("Login")
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

                // Anmeldebutton
                if isLoading {
                    ProgressView() // Ladeindikator
                        .padding(.top, 20)
                } else {
                    Button(action: {
                        Task {
                            isLoading = true // Ladezustand aktivieren
                            await userViewModel.loginUser(email: email, password: password)
                            isLoading = false // Ladezustand deaktivieren
                            
                            // Wenn der Benutzer erfolgreich eingeloggt ist, zur HomeView navigieren
                            if userViewModel.user != nil {
                                isLoggedIn = true
                            }
                        }
                    }) {
                        Text("Anmelden")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .accessibilityLabel("Anmeldebutton")
                            .accessibilityHint("Klicke hier, um dich anzumelden")
                    }
                    .padding(.top, 20)
                }

                // Anzeige einer Fehlermeldung, falls vorhanden
                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                        .accessibilityLabel("Fehlermeldung")
                        .accessibilityHint(errorMessage)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                // Überprüfen, ob der Benutzer bereits angemeldet ist
                Task {
                    await userViewModel.checkCurrentUser()
                }
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                MainTabView() // Weiterleitung zur MainTabView nach erfolgreichem Login
            }
        }
    }
}

#Preview {
    LoginView(userViewModel: UserViewModel())
}
