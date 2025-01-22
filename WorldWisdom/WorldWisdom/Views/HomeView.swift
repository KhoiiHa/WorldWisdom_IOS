//
//  HomeView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 22.01.25.
//

import SwiftUI

struct HomeView: View {
    // Beispiel-Text, der die erfolgreiche Anmeldung zeigt
    @State private var userEmail: String? = "Beispiel@benutzer.com"

    var body: some View {
        NavigationView {
            VStack {
                Text("Willkommen zur HomeView!")
                    .font(.largeTitle)
                    .padding()

                if let email = userEmail {
                    Text("Angemeldeter Benutzer: \(email)")
                        .padding()
                        .foregroundColor(.green)
                }

                Spacer()

                // Beispielbutton, um die Anmeldung zu beenden (log-out)
                Button("Abmelden") {
                    // Hier kannst du die Logik zum Abmelden implementieren, zum Beispiel:
                    // userViewModel.logoutUser()
                    print("Benutzer abgemeldet")
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
