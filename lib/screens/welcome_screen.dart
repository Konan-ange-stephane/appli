import 'package:flutter/material.dart';
import 'package:telecommande/screens/manette_screen.dart';
import 'package:telecommande/screens/telecommande_screen.dart';

/// Écran d'accueil permettant de choisir entre Mode Manette et Mode Télécommande
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Télécommande Voiture'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManetteScreen(),
                  ),
                );
              },
              child: const Text('Mode Manette'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelecommandeScreen(),
                  ),
                );
              },
              child: const Text('Mode Télécommande'),
            ),
          ],
        ),
      ),
    );
  }
}

