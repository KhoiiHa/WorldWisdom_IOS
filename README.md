# WorldWisdom 🌟📖

# **“Entdecke die Weisheit der Welt in einer App”** 🌍💬

WorldWisdom ist eine Zitat-App, die eine Sammlung inspirierender Zitate von Persönlichkeiten aus verschiedenen Bereichen wie Literatur, Wissenschaft und Philosophie bietet. Sie hilft Nutzern, sich zu motivieren und zu inspirieren, um ihre persönliche und berufliche Entwicklung zu fördern. 🚀💡

Die App richtet sich an Menschen, die nach Inspiration suchen – von Studenten 📚 über Berufstätige 💼 bis zu kreativen Köpfen 🎨.

---

## Design 🎨

<div style="display: flex; justify-content: space-between;">
  <img src="https://res.cloudinary.com/dpaehynl2/image/upload/v1740135025/Bildschirmfoto_2025-02-21_um_11.48.02_pafz2v.png" alt="Home Screen" width="150" />
  <img src="https://res.cloudinary.com/dpaehynl2/image/upload/v1740135032/Bildschirmfoto_2025-02-21_um_11.47.33_ppjgsv.png" alt="Explorer Screen" width="150" />
  <img src="https://res.cloudinary.com/dpaehynl2/image/upload/v1740135042/Bildschirmfoto_2025-02-21_um_11.48.32_abovgm.png" alt="Favoriten Screen" width="150" />
  <img src="https://res.cloudinary.com/dpaehynl2/image/upload/v1740135053/Bildschirmfoto_2025-02-21_um_11.49.11_bgiefm.png" alt="AutorDetail Screen" width="150" />
</div>


## Features ✨

- [ ] **Benutzer bleiben angemeldet (App-Status speichern)** 🔐  
- [ ] **Inspirierende Zitate**: Abruf von Zitate über die **Mockoon API** 🌍💬  
- [ ] **Lieblingszitate speichern**: Nutzer können Zitate speichern, um sie jederzeit wieder anzusehen 💖  
- [ ] **Filteroptionen**: Zitate nach Kategorien wie **Motivation**, **Erfolg**, **Glück** filtern 🔍
- [ ] **Suchoptionen**: Zitate nach Kategorien und Autoren suchen 🔍    
- [ ] **Autoren-Detailansicht**: Mehr Informationen über die Persönlichkeiten hinter den Zitaten ✍️👤  
- [ ] **Zitate Sammlung**: Eigene Sammlung der Lieblingszitate auf einem separaten Screen 📚🌟  

---

## Technischer Aufbau 🛠️

#### Projektstruktur
Die App folgt dem **MVVM-Designmuster** (Model-View-ViewModel), um eine klare Trennung zwischen der Logik und der Benutzeroberfläche zu gewährleisten.  
- **Views**: UI-Komponenten, erstellt mit **SwiftUI** 🖥️  
- **ViewModels**: Geschäftslogik und API-Kommunikation 🔄  
- **Models**: Strukturierte Datenobjekte für Zitate und Autoren 📋  

#### Datenspeicherung 💾
Die App nutzt **Firebase** für:  
- **Authentication**: Sichere Anmeldung via E-Mail/Passwort oder anonyme Anmeldung 🔑  
- **Firestore Database**: Speicherung von benutzerspezifischen Daten wie Anmeldedaten und Lieblingszitaten 📥  

Für die Speicherung von Bildern verwendet die App **Cloudinary**:
- **Cloudinary**: Speicherung von Medien wie Autorenbildern oder anderen Bildern, die zu den Zitaten gehören 📸🌐

**Warum Firebase und Cloudinary?**  
Firebase bietet eine einfache Integration in iOS-Projekte und unterstützt Echtzeit-Datenabgleich sowie Skalierbarkeit 🌐. Cloudinary ist eine leistungsstarke Plattform für die Verwaltung und Bereitstellung von Bildern und Videos in der Cloud.

#### Fehlerbehandlung & Validierung 🛡️
- **E-Mail und Passwort**: Verifizierung der Eingaben für eine sichere Anmeldung 💬✅  
- **Fehlermeldungen**: Klare und hilfreiche Hinweise bei fehlerhaften Eingaben 🚫💡

#### API Calls 🌐
Die App ruft Zitate aus der **Mockoon API** ab, um den Nutzern ständig frische Weisheiten zu bieten 🧠💭

#### 3rd-Party Frameworks 📦
- **Firebase SDK**: Für Authentication 🔑📦  
- **Cloudinary SDK**: Für die Verwaltung und Speicherung von Bildern 📸📦  
- **URLSession**: Für API-Aufrufe 🌐🔌  

---

## Ausblick 🔮

- [ ] **Push-Benachrichtigungen**: Benachrichtigungen über neue Zitate und Updates 🔔  
- [ ] **Community-Features**: Benutzer können eigene Zitate einreichen und teilen ✍️💬  
- [ ] **Like & Kommentar-System**: Zitate liken und kommentieren 💖🗨️  
- [ ] **Medienintegration**: Bilder, Videos und andere Medien in Zitate einbinden 🖼️🎥  
- [ ] **Mehrsprachigkeit**: Unterstützung für mehrere Sprachen 🌍💬  

---

### Werde Teil der Weisheit! ✨💡

Lass dich inspirieren und finde deine tägliche Dosis an Motivation – für deine persönliche und berufliche Reise! 🚀🌟
