<p align="center">
  <img src="https://res.cloudinary.com/dpaehynl2/image/upload/v1747579900/WorldWisdom_App_tvuuor.png" alt="WorldWisdom Icon" width="120" />
</p>


# WorldWisdom 🌟📖  

## „Entdecke die Weisheit der Welt – in einer App“ 🌍💬  

**WorldWisdom** ist eine native iOS-Zitat-App, die motivierende und tiefgründige Zitate aus Literatur, Wissenschaft und Philosophie vereint.  
Ob für Studierende 📚, Berufstätige 💼 oder kreative Köpfe 🎨 – die App begleitet dich mit klugen Gedanken durch deinen Tag.  

---

## 📱 Design-Eindrücke  

| Home View | Explorer View | Favoriten View | Autoren-Detail View | Galerie View | Info View | Settings View |
|-----------|---------------|----------------|---------------------|--------------|-----------|----------------|
| ![Home](https://res.cloudinary.com/dpaehynl2/image/upload/v1747577934/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-18_at_16.11.03_aa5zkj.png) | ![Explorer](https://res.cloudinary.com/dpaehynl2/image/upload/v1747577934/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-18_at_16.11.14_f1k3kd.png) | ![Favoriten](https://res.cloudinary.com/dpaehynl2/image/upload/v1747577932/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-18_at_16.12.34_g2cflh.png) | ![AutorDetail](https://res.cloudinary.com/dpaehynl2/image/upload/v1747577935/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-18_at_16.11.43_aqo0fw.png) | ![Galerie](https://res.cloudinary.com/dpaehynl2/image/upload/v1747577935/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-18_at_16.12.42_qcgswh.png) | ![Info](https://res.cloudinary.com/dpaehynl2/image/upload/v1747577932/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-18_at_16.10.11_t5ggch.png) | ![Settings](https://res.cloudinary.com/dpaehynl2/image/upload/v1747577930/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-18_at_16.15.13_f9jqrh.png) |

---

## ✨ Funktionen  

- [x] **Zitat des Tages + Empfehlungen** über Mockoon API  
- [x] **Favoriten speichern und verwalten** 💖  
- [x] **Autorengalerie mit Live-Suche und A–Z-Sortierung** 📚🔍  
- [x] **Autoren-Detailansicht mit Bild, Biografie & Zitaten** 👤  
- [x] **Offline-Modus mit SwiftData (Fallback bei fehlender API)**  
- [x] **Dark Mode** (standardmäßig aktiviert; umschaltbar in den Einstellungen) 🌙  
- [x] **Automatischer Login** über Firebase Auth  
- [x] **Zitate nach Kategorien filtern**  

---

## 🧠 Architektur & Technik  

### 🧱 Architektur
- **MVVM** – saubere Trennung von View, Logik und Datenfluss  
- **SwiftUI** – moderne, deklarative UI  
- **SwiftData** – persistente Offline-Datenhaltung  
- **Firebase** – Authentifizierung & Cloud-Speicherung  

### 🔐 Datenverwaltung
- **Firebase Authentication** (anonym oder via E-Mail)  
- **Cloud Firestore** zur Speicherung der Favoriten  
- **SwiftData** als Fallback bei fehlender Internetverbindung  
- **Cloudinary** für das dynamische Laden der Autorenbilder  

### 🌐 API & Netzwerk
- **Mockoon REST API** simuliert die produktive API lokal  
- **URLSession** für Netzwerkanfragen mit Fehlerbehandlung  
- **`NetworkMonitor.swift`** zur automatischen Umschaltung bei fehlender Verbindung  

### 🔍 Suche & Filter
- Live-Autorensuche in der GalerieView  
- Alphabetische Sortierung  
- Automatische Validierung ungültiger Einträge  

### 📦 Frameworks & Tools
- `Firebase SDK`  
- `Cloudinary SDK`  
- `SwiftData`, `URLSession`  
- `SDWebImageSwiftUI`, `SwiftLint`  
- `Xcode`, `GitHub`, `Mockoon`  

---

## 🤖 Einsatz von KI (z. B. ChatGPT)

**WorldWisdom** wurde technisch, strukturell und textlich mit Unterstützung von **ChatGPT Plus 4.0** entwickelt.  
Der Einsatz erfolgte gezielt in folgenden Bereichen:

- Strukturierung & Architekturberatung  
- SwiftData-Fallback & Fehlerbehandlung  
- Debugging, Refactoring & Testing  
- Textoptimierung von UI & README  
- Unterstützung bei Feature-Entscheidungen  

> Die finale Umsetzung erfolgte **vollständig manuell** in Swift & SwiftUI.  
> ChatGPT diente als technischer Sparringspartner im Entwicklungsprozess.

---

## 🔮 Geplante Erweiterungen

- [ ] Push Notifications für tägliche Zitate  
- [ ] Eigene Zitate veröffentlichen (Community-Funktion)  
- [ ] Kommentar- & Like-System  
- [ ] Apple Sign-In & CloudKit  
- [ ] Mehrsprachigkeit (DE/EN)  
- [ ] Lokaler Zitat-Editor mit Entwürfen  

---

## ⚠️ Hinweis zu Bugs & Weiterentwicklung

Diese App ist funktional stabil, **wird aber weiterhin aktiv optimiert**.  
Kleinere Bugs oder visuelle Ungenauigkeiten können vorkommen – insbesondere bei:

- Wechsel zwischen Authentifizierungsstatus  
- Dark-Mode-Darstellung bei Fallback-Daten  
- Randfällen bei Kategorie-Filterung  

> Rückmeldungen oder Pull Requests sind jederzeit willkommen!

---

## 🚀 Motivation & Zielsetzung  

**WorldWisdom** entstand als iOS-Portfolio-App zur praxisnahen Umsetzung moderner Technologien:  
SwiftUI · Firebase · SwiftData · Offline-Modus · MVVM · API-Simulation

**Ziel:**  
- Stabiler Offline-Modus mit Fallback  
- Klar strukturierter SwiftUI-Code  
- Modularer Aufbau mit ViewModels  
- Realistische App-Nutzung – auch im Bewerbungsprozess

---

## 👨‍💻 Über den Entwickler

> 👋 Entwickelt von **Minh Khoi Ha**  
> 📍 Hamburg · App Developer seit 2024  
> 💡 Fokus: SwiftUI · SwiftData · Firebase · Offline-First Apps

---

### 📂 Quellcode & Lizenz

Dieses Projekt ist Open Source und dient ausschließlich zu Lern- und Demonstrationszwecken.  
**Lizenz:** MIT

---

**🧠 Lass dich inspirieren. Täglich. Direkt aus der Hosentasche.**  
📲 Jetzt ausprobieren & WorldWisdom erleben.

---

*📘 Diese README ist auf Deutsch verfasst. Eine englische Version folgt bei Bedarf.*
