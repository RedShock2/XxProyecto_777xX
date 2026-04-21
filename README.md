<div align="center">

# PokéForge
### Competitive Pokémon Team Builder

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
<img src="https://img.shields.io/badge/PokéAPI-v2-EF5350?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge&logo=android"/>
<img src="https://img.shields.io/badge/Status-In%20Development-yellow?style=for-the-badge"/>

> App móvil para construir, analizar y compartir equipos Pokémon competitivos.  
> Busca cualquier Pokémon, arma tu equipo de 6, analiza coberturas de tipo y comparte tu roster con un QR.

</div>

---

## Características

| Módulo | Descripción |
|---|---|
| **Buscador** | Busca más de 1000 Pokémon en tiempo real via PokéAPI con caché local |
| **Team Builder** | Arma equipos de hasta 6 miembros con slots drag-and-drop |
| **Análisis** | Visualiza stats base, cobertura de debilidades y gráficas comparativas |
| **Mapa GPS** | Localiza tu región y explora puntos de interés en el mapa |
| **QR Sharing** | Genera un código QR de tu equipo y escanea el de otros entrenadores |
| **Cámara** | Captura y usa imágenes de galería para personalizar tu perfil de entrenador |

---

## Capturas de pantalla

> *Coming soon — screenshots will be added on first stable release.*

---

## Stack tecnológico

```
Flutter 3.x / Dart 3.x
├── State Management    Provider 6
├── Networking          HTTP · Dio · cached_network_image
├── Maps                Google Maps Flutter · Geolocator
├── Camera / Gallery    camera · image_picker
├── QR                  qr_flutter · mobile_scanner
├── Storage             shared_preferences · path_provider
└── UI                  fl_chart · Lottie · Shimmer · Material 3
```

---

## Arquitectura

```
lib/
├── main.dart                   Entry point + MultiProvider setup
├── app.dart                    MaterialApp + named routes
│
├── models/
│   ├── pokemon.dart            Pokémon entity (stats, types, moves)
│   ├── team.dart               Team entity (up to 6 Pokémon, JSON serializable)
│   └── trainer.dart            Trainer profile
│
├── services/
│   ├── pokeapi_service.dart    PokéAPI v2 REST client
│   ├── location_service.dart   GPS + geocoding
│   ├── camera_service.dart     Camera / gallery abstraction
│   └── storage_service.dart    Local persistence (SharedPreferences)
│
├── providers/
│   ├── pokemon_provider.dart   Search & selection state
│   ├── team_provider.dart      Team CRUD state
│   └── trainer_provider.dart   Trainer profile state
│
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── team_builder_screen.dart
│   ├── team_summary_screen.dart
│   ├── map_screen.dart
│   └── qr_screen.dart
│
├── widgets/
│   ├── pokemon_card.dart
│   ├── team_slot_widget.dart
│   ├── type_badge.dart
│   ├── stat_bar.dart
│   └── weakness_grid.dart
│
└── utils/
    ├── type_chart.dart         Tabla de efectividades de tipo
    ├── region_mapper.dart      Región → coordenadas GPS
    └── type_colors.dart        Colores canónicos por tipo
```

---

## Requisitos previos

- Flutter SDK `>=3.0.0`
- Android Studio + Android SDK API 21+
- Xcode 14+ *(solo iOS)*
- Google Maps API Key

---

## Setup

### 1. Clonar e instalar dependencias

```bash
git clone https://github.com/<tu-usuario>/pokeforge.git
cd pokeforge
flutter pub get
```

### 2. Configurar Google Maps

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI"/>
```

**iOS** — `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps
GMSServices.provideAPIKey("TU_API_KEY_AQUI")
```

### 3. Correr la app

```bash
# Android
flutter run

# iOS
cd ios && pod install && cd ..
flutter run
```

---

## Permisos requeridos

| Permiso | Módulo |
|---|---|
| `INTERNET` | PokéAPI |
| `ACCESS_FINE_LOCATION` | GPS / Mapa |
| `CAMERA` | Cámara / Escáner QR |
| `READ_MEDIA_IMAGES` | Galería |

---

## Equipo

| Integrante | Módulo |
|---|---|
| **Luis Antonio Padilla Mondragón** | UI · Widgets · Navegación |
| **Juan Luis Ramírez Hernández** | PokéAPI · Async / Dart |
| **Uriel Everardo Sánchez Rangel** | Módulo GPS |
| **Luis Alejandro Alcocer Marín** | Módulo Cámara |

---

## API

Este proyecto consume [PokéAPI v2](https://pokeapi.co/) — una API pública, gratuita y sin autenticación requerida.

---

<div align="center">

Made with Flutter · Powered by PokéAPI

</div>