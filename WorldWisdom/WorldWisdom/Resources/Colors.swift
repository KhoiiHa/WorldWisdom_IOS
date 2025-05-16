//
//  Colors.swift
//  WorldWisdom
//
//  Enthält alle zentralen Farbdefinitionen für Light & Dark Mode.
//  Die Farben werden über den Asset-Katalog gepflegt und hier zentral im Code verwendet.
//  So bleibt das Farbsystem konsistent und wartbar.
//
//  Tipp: Neue Farben immer zuerst im Asset-Katalog und dann hier eintragen!
//
//  Stand: Mai 2025
//

import SwiftUI

struct Colors {
    // MARK: - Hintergrundfarben
    static let background = Color("background")            // Haupt-App-Hintergrund
    static let cardBackground = Color("cardBackground")    // Cards und Listenelemente

    // MARK: - Textfarben
    static let primaryText = Color("primaryText")
    static let secondaryText = Color("secondaryText")

    // MARK: - Akzent- & Buttonfarben
    static let accentColor = Color("accentColor")
    static let buttonColor = Color("buttonColor")
}
