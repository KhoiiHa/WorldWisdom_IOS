//
//  LoginView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 21.01.25.
//

import SwiftUI

struct LoginView: View {
    // Bindings für die Eingabefelder
    @State private var email: String = ""
    @State private var password: String = ""
    
    // Instanz des ViewModels
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack {
            // Titel der Seite
            Text("Login")
                .font(.largeTitle)
                .padding()
            
            // Eingabefeld für die E-Mail
            TextField("E-Mail", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            // Eingabefeld für das Passwort
            SecureField("Passwort", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Anmeldebutton
            Button(action: {
                Task {
                    // Login durchführen
                    await userViewModel.loginUser(email: email, password: password)
                }
            }) {
                Text("Anmelden")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            // Anzeige einer Fehlermeldung, falls vorhanden
            if let errorMessage = userViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // Hier kannst du die LoginView im Preview-Modus anzeigen
        LoginView(userViewModel: UserViewModel())
    }
}

#Preview {
    LoginView(userViewModel: <#UserViewModel#>)
}
