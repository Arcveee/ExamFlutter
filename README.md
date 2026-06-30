# BadWallet Mobile

Application mobile Flutter consommant l'API **BadWallet** (Spring Boot).

## Description

BadWallet Mobile est une application de portefeuille électronique qui permet :
- 🔐 Authentification par numéro de téléphone + PIN
- 💰 Consultation du solde en temps réel
- 📤 Envoi d'argent entre utilisateurs
- 🧾 Paiement de factures (eau, électricité, internet)
- 📜 Historique complet des transactions

## Architecture

```
lib/
├── core/           # Config, thème, constantes, utilitaires
├── features/       # Modules fonctionnels (feature-first)
│   ├── auth/
│   ├── dashboard/
│   ├── transfers/
│   ├── bills/
│   └── history/
└── shared/         # Widgets, modèles et services partagés
```

## Configuration API

- **Backend** : BadWallet API (Spring Boot)
- **URL locale (dev)** : `http://localhost:8080`
- **URL émulateur Android** : `http://10.0.2.2:8080`
- **Livrable** : `build/app/outputs/flutter-apk/app-release.apk`

## Lancer le projet

```bash
# Installer les dépendances
flutter pub get

# Lancer en debug (émulateur Android)
flutter run

# Générer l'APK de release
flutter build apk --release
```

## Branches Git

| Branche | Rôle |
|---------|------|
| `main` | Code stable — merge taggué uniquement |
| `develop` | Branche d'intégration |
| `feature/*` | Développement des fonctionnalités |
