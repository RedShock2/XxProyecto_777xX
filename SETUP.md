# XxProyecto_777xX — Instrucciones de Setup

## Requisitos previos
- Flutter SDK >= 3.0.0 ([flutter.dev](https://flutter.dev/docs/get-started/install))
- Android Studio + Android SDK (API 21+)
- Xcode 14+ (solo para iOS)
- Una Google Maps API Key (para el módulo GPS)

## 1. Instalar dependencias

```bash
flutter pub get
```

## 2. Configurar Google Maps

**Android** — edita `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI"/>
```

**iOS** — en `ios/Runner/AppDelegate.swift` agrega:
```swift
import GoogleMaps
GMSServices.provideAPIKey("TU_API_KEY_AQUI")
```

## 3. Configurar rutas locales (Android)

Edita `android/local.properties` con las rutas reales de tu máquina:
```
sdk.dir=C\:\\Users\\TU_USUARIO\\AppData\\Local\\Android\\Sdk
flutter.sdk=C\:\\flutter
```

## 4. Correr la app

```bash
# Android
flutter run

# iOS
cd ios && pod install && cd ..
flutter run
```

## Estructura del proyecto

```
lib/
├── main.dart              # Entry point + MultiProvider
├── app.dart               # MaterialApp + rutas nombradas
├── models/                # Pokemon, Team, Trainer
├── services/              # PokeApiService, LocationService, CameraService, StorageService
├── providers/             # PokemonProvider, TeamProvider, TrainerProvider
├── screens/               # splash, home, search, team_builder, team_summary, map, qr
├── widgets/               # pokemon_card, team_slot, type_badge, stat_bar, weakness_grid
└── utils/                 # TypeChart, RegionMapper, TypeColors
```

## Permisos requeridos

| Permiso | Módulo |
|---------|--------|
| INTERNET | PokéAPI |
| ACCESS_FINE_LOCATION | GPS |
| CAMERA | Cámara / QR |
| READ_MEDIA_IMAGES | Galería |

## Responsabilidades del equipo

| Integrante | Módulo |
|------------|--------|
| Luis Antonio Padilla Mondragón | UI / Widgets & Navegación |
| Juan Luis Ramírez Hernández | PokéAPI (Async/Dart) |
| Uriel Everardo Sánchez Rangel | Módulo GPS |
| Luis Alejandro Alcocer Marín | Módulo Cámara |
