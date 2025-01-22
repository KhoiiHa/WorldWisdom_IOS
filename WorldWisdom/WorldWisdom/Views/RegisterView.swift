//
//  RegisterView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import SwiftUI

struct RegisterView: View {
    // Bindings für die Eingabefelder
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false // Ladezustand

    // Instanz des ViewModels
    @ObservedObject var userViewModel: UserViewModel

    var body: some View {
        VStack {
            // Titel der Seite
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

            // Registrierungsbutton
            if isLoading {
                ProgressView() // Ladeindikator
                    .padding(.top, 20)
            } else {
                Button(action: {
                    Task {
                        isLoading = true // Ladezustand aktivieren
                        await userViewModel.registerUser(email: email, password: password)
                        isLoading = false // Ladezustand deaktivieren
                    }
                }) {
                    Text("Registrieren")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .accessibilityLabel("Registrierungsbutton")
                        .accessibilityHint("Klicke hier, um dich zu registrieren")
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
            userViewModel.checkCurrentUser()
        }
    }
}

#Preview {
    RegisterView(userViewModel: UserViewModel())
}
