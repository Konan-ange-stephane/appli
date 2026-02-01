# Télécommande Voiture - Application Flutter

Application Flutter permettant de contrôler un robot Arduino via Bluetooth.

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
│   └── bluetooth_service.dart   # Service de communication Bluetooth
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

### Mode Télécommande
- Interface avec pad de direction circulaire
- Boutons directionnels :
  - **Avancer** (A)
  - **Reculer** (R)
  - **Gauche** (G)
  - **Droite** (D)
- **Slider de vitesse** (50-255) - pour référence visuelle uniquement
- **Bouton STOP** (S)
- **Indicateur de connexion Bluetooth** - cliquer pour scanner et se connecter/déconnecter

### Service de commandes
Le `CommandService` centralise l'envoi des messages via Bluetooth vers l'Arduino.

**Format des commandes (protocole Arduino) :**
- `A` → Avancer
- `R` → Reculer
- `G` → Tourner à gauche
- `D` → Tourner à droite
- `S` → Stop

**Note :** L'Arduino attend un seul caractère. Les commandes avec vitesse (ex: `F:150`) ne sont pas supportées.

## Connexion à l'Arduino

### Prérequis
1. Module Bluetooth (HC-05, HC-06, ou similaire) connecté à l'Arduino
2. Code Arduino chargé sur la carte avec support Bluetooth Serial
3. Bluetooth activé sur votre appareil (téléphone/tablette/ordinateur)
4. Module Bluetooth appairé avec votre appareil

### Étapes de connexion
1. Activer Bluetooth sur votre appareil
2. Lancer l'application
3. Aller dans le mode **Télécommande**
4. Cliquer sur l'indicateur de connexion Bluetooth en haut
5. Si Bluetooth est désactivé, l'application proposera de l'activer
6. L'application va scanner les appareils Bluetooth disponibles
7. Sélectionner votre module Bluetooth (ex: HC-05, HC-06)
8. L'indicateur passera à "Connecté" en vert

### Configuration Bluetooth
- L'application utilise le service Serial Bluetooth standard
- Le module Bluetooth doit être configuré en mode Serial (SPP)
- Baud rate recommandé : 9600 (configuré dans le code Arduino)

## Code Arduino

Le code Arduino attend les commandes suivantes via Serial (9600 baud) :
- `A` : Avancer (moteurs à vitesse max)
- `R` : Reculer (moteurs à vitesse max)
- `G` : Tourner à gauche (vitesses différenciées)
- `D` : Tourner à droite (vitesses différenciées)
- `S` : Arrêter tous les moteurs

## Getting Started

1. Installer les dépendances :
```bash
flutter pub get
```

2. Connecter l'Arduino et charger le code fourni

3. Lancer l'application :
```bash
flutter run
```

4. Se connecter à l'Arduino via l'interface

## Dépendances

- `flutter_blue_plus` : Communication Bluetooth avec l'Arduino

## Notes

- Les commandes Klaxon (H) et Phares (LON/LOFF) ne sont pas encore implémentées dans le code Arduino
- Le slider de vitesse est présent pour référence visuelle, mais l'Arduino utilise des vitesses fixes
- L'application fonctionne sur Linux, Windows et macOS
