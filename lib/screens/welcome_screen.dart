import 'package:flutter/material.dart';
import 'package:telecommande/screens/manette_screen.dart';
import 'package:telecommande/screens/telecommande_screen.dart';

/// Écran d'accueil permettant de choisir entre les différents modes
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titre
              const Text(
                'TÉLÉCOMMANDE ROBOT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 50),

              // Bouton Mode Télécommande
              _buildModeButton(
                context: context,
                title: 'TÉLÉCOMMANDE',
                icon: Icons.gamepad,
                color: const Color(0xFF1A4D21),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelecommandeScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Bouton Mode Manette
              _buildModeButton(
                context: context,
                title: 'MANETTE',
                icon: Icons.sports_esports,
                color: const Color(0xFF0D3A3A),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManetteScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2ECC71).withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 50),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
