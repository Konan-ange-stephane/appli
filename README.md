# Télécommande Voiture - Application Flutter

Application Flutter permettant de contrôler une voiture grâce à deux modes : **Manette** et **Télécommande**.

## Structure du projet

```
lib/
├── main.dart                    # Point d'entrée de l'application
├── screens/                     # Écrans de l'application
│   ├── welcome_screen.dart      # Écran d'accueil (choix du mode)
│   ├── manette_screen.dart      # Mode Manette
│   └── telecommande_screen.dart # Mode Télécommande
├── widgets/                     # Widgets réutilisables
│   ├── direction_button.dart    # Bouton directionnel
│   ├── speed_slider.dart        # Slider de vitesse
│   └── stop_button.dart         # Bouton STOP
├── services/                    # Services de communication
│   ├── command_service.dart     # Service centralisé d'envoi de commandes
│   └── bluetooth_service.dart   # Service Bluetooth
├── models/                      # Modèles de données
│   └── command.dart             # Modèle de commande
└── utils/                       # Utilitaires
    └── constants.dart           # Constantes de l'application
```

## Architecture

### Écran d'accueil (Welcome Screen)
- Deux boutons pour choisir entre :
  - **Mode Manette**
  - **Mode Télécommande**

### Mode Manette
- Boutons directionnels :
  - **Avant** (F:x)
  - **Arrière** (B:x)
  - **Gauche** (L:x)
  - **Droite** (R:x)
- **Slider de vitesse** (0-255)
- **Bouton STOP** (S)

### Mode Télécommande
- Interface alternative plus minimaliste
- À implémenter selon les besoins

### Service de commandes
Le `CommandService` centralise l'envoi des messages via Bluetooth.

**Format des commandes :**
- `F:x` → Avancer (Forward) avec vitesse x
- `B:x` → Reculer (Backward) avec vitesse x
- `L:x` → Gauche (Left) avec vitesse x
- `R:x` → Droite (Right) avec vitesse x
- `S` → Stop

## Getting Started

1. Installer les dépendances :
```bash
flutter pub get
```

2. Lancer l'application :
```bash
flutter run
```

## TODO

- [ ] Implémenter la logique Bluetooth
- [ ] Finaliser l'interface Mode Télécommande
- [ ] Ajouter la gestion des erreurs
- [ ] Ajouter les tests unitaires
