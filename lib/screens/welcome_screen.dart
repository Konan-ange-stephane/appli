import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telecommande/screens/manette_screen.dart';
import 'package:telecommande/screens/telecommande_screen.dart';

/// Écran d'accueil avec choix du mode de contrôle
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Couleurs du thème
  static const Color primaryGreen = Color(0xFF1A4D21);
  static const Color darkGreen = Color(0xFF183E1D);
  static const Color accentGreen = Color(0xFF2ECC71);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fond avec grille
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(),
          ),

          // Cercles décoratifs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryGreen.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryGreen.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Logo / Icône
                      _buildLogo(),

                      const SizedBox(height: 20),

                      // Titre
                      _buildTitle(),

                      const SizedBox(height: 10),

                      // Sous-titre
                      Text(
                        'Contrôlez votre véhicule',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Cartes de sélection
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildModeCard(
                              title: 'MODE MANETTE',
                              subtitle: 'Contrôle style gamepad',
                              icon: Icons.sports_esports,
                              delay: 200,
                              onTap: () => _navigateTo(const ManetteScreen()),
                            ),
                            const SizedBox(height: 20),
                            _buildModeCard(
                              title: 'MODE TÉLÉCOMMANDE',
                              subtitle: 'Contrôle tactile précis',
                              icon: Icons.touch_app,
                              delay: 400,
                              onTap: () => _navigateTo(const TelecommandeScreen()),
                            ),
                          ],
                        ),
                      ),

                      // Footer
                      _buildFooter(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryGreen, darkGreen],
        ),
        boxShadow: [
          BoxShadow(
            color: accentGreen.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
        border: Border.all(color: accentGreen.withOpacity(0.5), width: 2),
      ),
      child: const Icon(
        Icons.directions_car,
        color: Colors.white,
        size: 50,
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [Colors.white, accentGreen],
      ).createShader(bounds),
      child: const Text(
        'RC CONTROL',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 6,
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryGreen.withOpacity(0.4),
                darkGreen.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryGreen.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icône
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryGreen,
                  boxShadow: [
                    BoxShadow(
                      color: accentGreen.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              // Textes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Flèche
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentGreen.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Indicateur de connexion
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryGreen.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'En attente de connexion',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'v1.0.0',
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

/// Grille de fond décorative
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A4D21).withOpacity(0.1)
      ..strokeWidth = 0.5;

    const double spacing = 30;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
