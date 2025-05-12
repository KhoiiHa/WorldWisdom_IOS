//
//  Colors.swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 21.02.25.
//

import SwiftUI

/// Enthält zentrale Farbdefinitionen für Light & Dark Mode.
/// Verwendet benannte Farben aus dem Asset-Katalog (Colors.xcassets).
/// So wird sichergestellt, dass UI-Elemente konsistent gestylt bleiben.

struct Colors {
    // MARK: - Light Mode Farben (aus Assets)
    static let lightBackground = Color("lightBackground")
    static let darkBackground = Color("darkBackground")
    static let primaryText = Color("primaryText")
    static let secondaryText = Color("secondaryText")
    static let buttonColor = Color("buttonColor")
    static let accentColor = Color("accentColor")
    
    // MARK: - Dark Mode Farben (aus Assets)
    static let darkPrimaryText = Color("darkPrimaryText")
    static let darkSecondaryText = Color("darkSecondaryText")
    static let darkButtonColor = Color("darkButtonColor")
}
