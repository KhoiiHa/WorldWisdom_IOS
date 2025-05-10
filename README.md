# WorldWisdom 🌟📖  

## **“Entdecke die Weisheit der Welt in einer App”** 🌍💬  

WorldWisdom ist eine Zitat-App, die eine Sammlung inspirierender Zitate von Persönlichkeiten aus verschiedenen Bereichen wie Literatur, Wissenschaft und Philosophie bietet. Sie hilft Nutzern, sich zu motivieren und zu inspirieren, um ihre persönliche und berufliche Entwicklung zu fördern. 🚀💡  

Die App richtet sich an Menschen, die nach Inspiration suchen – von Studenten 📚 über Berufstätige 💼 bis zu kreativen Köpfen 🎨.  

---

## 📱 Design-Eindrücke *(in Bearbeitung – folgen bald)*

| Home View | Explorer View | Favoriten View | Autoren-Detail View |
|-----------|---------------|----------------|---------------------|
| ![Home](https://res.cloudinary.com/dpaehynl2/image/upload/v1740401014/Bildschirmfoto_2025-02-24_um_13.40.36_d2a7p0.png) | ![Explorer](https://res.cloudinary.com/dpaehynl2/image/upload/v1740400996/Bildschirmfoto_2025-02-24_um_13.40.55_vil0lv.png) | ![Favoriten](https://res.cloudinary.com/dpaehynl2/image/upload/v1740401002/Bildschirmfoto_2025-02-24_um_13.41.21_dq1ija.png) | ![AutorDetail](https://res.cloudinary.com/dpaehynl2/image/upload/v1740401008/Bildschirmfoto_2025-02-24_um_13.42.27_aozvtr.png) |

---

## Features ✨  

- [x] **Automatischer Login**: Nutzer bleiben nach dem Start automatisch eingeloggt 🔐  
- [x] **Inspirierende Zitate**: Abruf über eine eigene **Mockoon API** 🌍💬  
- [x] **Favoriten speichern & verwalten** 💖  
- [x] **GalerieView mit Autorensuche & alphabetischer Sortierung** 📚🔍  
- [x] **Autoren-Detailansicht**: Mehr Infos über berühmte Persönlichkeiten 👤  
- [x] **Offline-Modus mit SwiftData**: App funktioniert auch ohne Internet 📴  
- [ ] **Filter nach Kategorien (kommt zurück)**  
- [ ] **Eigene Zitate eintragen (in Planung)**  

---

## Technischer Aufbau 🛠️  

### 🧱 Architektur
Die App basiert auf **MVVM (Model-View-ViewModel)** zur sauberen Trennung von UI und Logik.

- **Views**: Interface in SwiftUI  
- **ViewModels**: Logik, Datenfluss & API-Aufrufe  
- **Models**: Quote- & Author-Strukturen  

### 💾 Datenverwaltung  
- **Firebase Auth** für anonyme oder echte Anmeldung  
- **Firestore** für Nutzer-bezogene Daten wie Favoriten  
- **SwiftData** zur Offline-Speicherung der Zitate  
- **Cloudinary** für Autorenbilder  

### 🔍 Suche & Filterung  
- Autorensuche mit Live-Filtering in der Galerie  
- Autoren werden alphabetisch und fehlerfrei dargestellt  
- Leere oder ungültige Einträge werden automatisch ausgeschlossen  

### 🌐 API & Netzwerke  
- Abruf der Zitate erfolgt über **Mockoon API** (lokale Simulation)  
- `URLSession` für Netzwerkanfragen  

### 📦 Frameworks & Tools  
- `Firebase SDK`  
- `Cloudinary SDK`  
- `SwiftData`  
- `Kingfisher` oder `SDWebImageSwiftUI` (optional, für Bild-Handling)  
- `Xcode`, `SwiftLint`, `GitHub`  

---

## 🔮 Ausblick  

- [ ] **Push Notifications** für neue tägliche Zitate  
- [ ] **Eigene Beiträge & Community-Zitate**  
- [ ] **Kommentar- & Like-System**  
- [ ] **Dark Mode Verbesserungen**  
- [ ] **Mehrsprachige Unterstützung (EN/DE)**  

---

## ✨ Werde Teil der Weisheit!  

Lass dich inspirieren und finde deine tägliche Dosis an Motivation – für deine persönliche und berufliche Reise! 🚀🌟  

