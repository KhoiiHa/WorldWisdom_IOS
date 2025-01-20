# WorldWisdom

**“Entdecke die Weisheit der Welt in einer App”**

WorldWisdom ist eine Zitat-App, die eine Sammlung inspirierender Zitate von Persönlichkeiten aus verschiedenen Bereichen wie Literatur, Wissenschaft und Philosophie bietet.  
Ziel der App ist es, Menschen zu motivieren und zu inspirieren, um ihre persönliche und berufliche Entwicklung zu fördern.  

Die App richtet sich an Menschen, die Inspiration und Motivation suchen, darunter Studenten, Berufstätige und kreative Köpfe. Sie bietet einzigartige Funktionen wie Filteroptionen und eine Sammlung von Lieblingszitaten.

---

## Design
(*Screenshots werden später hinzugefügt.*)

---

## Features
- [ ] Abruf inspirierender Zitate über die **ZenQuotes API**.  
- [ ] Benutzer können ihre Lieblingszitate speichern.  
- [ ] Filteroptionen für Zitate (z. B. Motivation, Erfolg, Glück).  
- [ ] Detailansicht für Autoren.  
- [ ] Sammlung gespeicherter Lieblingszitate auf einem eigenen Screen anzeigen.  

---

## Technischer Aufbau

#### Projektaufbau
Die App basiert auf dem **MVVM-Muster** (Model-View-ViewModel), um eine klare Trennung zwischen Logik und UI zu gewährleisten.  
- **Views**: UI-Komponenten, die mit SwiftUI umgesetzt werden.  
- **ViewModels**: Geschäftslogik und API-Aufrufe.  
- **Models**: Datenstrukturen für Zitate und Autoren.  

#### Datenspeicherung
Die App verwendet **Firebase** für:  
- **Authentication**: Anonyme Anmeldung und E-Mail/Passwort-Registrierung.  
- **Storage**: Speicherung von benutzerspezifischen Daten wie Lieblingszitaten.  

**Warum Firebase?**  
Firebase bietet eine einfache Integration in iOS-Projekte und unterstützt Echtzeit-Datenabgleich sowie Skalierbarkeit.

#### API Calls
Die App nutzt die **ZenQuotes API**, um Zitate dynamisch abzurufen.  

#### 3rd-Party Frameworks
- **Firebase SDK**: Für Authentication und Storage.  
- **URLSession**: Für API-Aufrufe.  

---

## Ausblick
- [ ] Community-Funktion: Benutzer können eigene Zitate einreichen.  
- [ ] Möglichkeit, Zitate anderer Benutzer zu liken oder zu kommentieren.  
- [ ] Integration von Bildern und Medien.  
- [ ] Mehrsprachige App-Unterstützung.  
