//
//  StartView.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 10.05.25.
//

import SwiftUI

/// Startbildschirm mit Option zur anonymen Nutzung, Registrierung oder Anmeldung.
/// Führt bei Auswahl von „Los geht’s“ eine anonyme Firebase-Anmeldung aus.

// MARK: - StartView
struct StartView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var quoteViewModel: QuoteViewModel
    @State private var navigateToMain = false
    @State private var navigateToRegister = false
    @State private var navigateToLogin = false

    // MARK: - View Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrundverlauf
                LinearGradient(
                    colors: [Color("mainBlue").opacity(0.22), Color("buttonColor").opacity(0.16)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Buch-Symbol mit Hintergrund
                    Image(systemName: "book.fill")
                        .resizable()
                        .frame(width: 74, height: 74)
                        .foregroundColor(Color("mainBlue"))
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 94, height: 94)
                                .shadow(color: Color("mainBlue").opacity(0.12), radius: 14, y: 2)
                        )
                        .padding(.bottom, 10)
                    
                    // Begrüßungstexte
                    VStack(spacing: 0) {
                        Text("Willkommen bei")
                            .font(.title3)
                            .fontWeight(.medium)
                        Text("WorldWisdom")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color("mainBlue"))
                    }
                    
                    // Beschreibung
                    Text("Entdecke inspirierende Zitate – ohne Registrierung.")
                        .font(.body)
                        .foregroundColor(Color("secondaryText"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Button für anonyme Nutzung
                    Button("Los geht’s") {
                        Task {
                            await userViewModel.startWithoutAccount()
                            navigateToMain = true
                        }
                    }
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color("mainBlue"))
                    .foregroundColor(Color("primaryText"))
                    .cornerRadius(16)
                    .shadow(color: Color("mainBlue").opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Navigation zu Registrierung und Login
                    VStack(spacing: 12) {
                        NavigationLink("Oder registrieren", destination: RegisterView(userViewModel: userViewModel))
                        
                        NavigationLink("Schon ein Konto? Jetzt anmelden", destination: LoginView(userViewModel: userViewModel))
                            .font(.caption)
                            .padding(.bottom, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                    )
                    .shadow(color: Color("primaryText").opacity(0.1), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 24)
                }
            }
            // Navigation zur Hauptansicht nach anonymem Login
            .navigationDestination(isPresented: $navigateToMain) {
                MainTabView()
                    .environmentObject(userViewModel)
                    .environmentObject(quoteViewModel)
            }
        }
    }
}
