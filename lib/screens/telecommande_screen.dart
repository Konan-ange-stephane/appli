import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telecommande/services/command_service.dart';

/// Écran du Mode Télécommande - Interface avec pad de direction circulaire amélioré
class TelecommandeScreen extends StatefulWidget {
  const TelecommandeScreen({super.key});

  @override
  State<TelecommandeScreen> createState() => _TelecommandeScreenState();
}

class _TelecommandeScreenState extends State<TelecommandeScreen>
    with TickerProviderStateMixin {
  final CommandService _commandService = CommandService();
  bool isJoystickMode = false;
  bool isConnected = false;
  bool lightsOn = false;
  double _speed = 150.0;

  // États des boutons pour l'animation
  String? _activeButton;

  // Couleurs du thème
  static const Color primaryGreen = Color(0xFF1A4D21);
  static const Color darkGreen = Color(0xFF183E1D);
  static const Color tealGreen = Color(0xFF0D3A3A);
  static const Color accentGreen = Color(0xFF2ECC71);

  void _onButtonPressed(String direction, String command) {
    HapticFeedback.mediumImpact();
    setState(() => _activeButton = direction);
    _commandService.sendCommand('$command:${_speed.toInt()}');
    debugPrint('$direction - Vitesse: ${_speed.toInt()}');
  }

  void _onButtonReleased() {
    setState(() => _activeButton = null);
    _commandService.sendCommand('S');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Fond avec effet de grille subtile
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(),
            ),

            // Contenu principal scrollable
            Column(
              children: [
                // Header personnalisé (fixe)
                _buildHeader(),

                // Contenu scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Indicateurs en haut
                        _buildIndicators(),

                        const SizedBox(height: 15),

                        // Pad directionnel principal
                        _buildDirectionalPad(),

                        const SizedBox(height: 20),

                        // Slider de vitesse
                        _buildSpeedSlider(),

                        const SizedBox(height: 15),

                        // Boutons d'action (klaxon, phares)
                        _buildActionButtons(),

                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),

                // Barre de navigation en bas (fixe)
                _buildBottomBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton retour
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryGreen.withOpacity(0.5)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
            ),
          ),

          // Titre
          const Text(
            'TÉLÉCOMMANDE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),

          // Bouton menu
          GestureDetector(
            onTap: () => debugPrint('Menu'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryGreen.withOpacity(0.5)),
              ),
              child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Indicateur Bluetooth
          _buildIndicator(
            icon: Icons.bluetooth,
            label: isConnected ? 'Connecté' : 'Déconnecté',
            isActive: isConnected,
            onTap: () {
              setState(() => isConnected = !isConnected);
              HapticFeedback.lightImpact();
            },
          ),

          // Indicateur de batterie
          _buildIndicator(
            icon: Icons.battery_full,
            label: '85%',
            isActive: true,
          ),

          // Indicateur de signal
          _buildIndicator(
            icon: Icons.signal_cellular_alt,
            label: 'Fort',
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator({
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? primaryGreen.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? accentGreen.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? accentGreen : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionalPad() {
    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cercle externe avec glow
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryGreen.withOpacity(0.4),
                    darkGreen.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),

            // Cercle intermédiaire
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryGreen.withOpacity(0.4),
                  width: 2,
                ),
              ),
            ),

            // Bouton Haut (Avancer)
            Positioned(
              top: 15,
              child: _buildDirectionButton(
                direction: 'up',
                icon: Icons.keyboard_arrow_up,
                command: 'F',
              ),
            ),

            // Bouton Bas (Reculer)
            Positioned(
              bottom: 15,
              child: _buildDirectionButton(
                direction: 'down',
                icon: Icons.keyboard_arrow_down,
                command: 'B',
              ),
            ),

            // Bouton Gauche
            Positioned(
              left: 15,
              child: _buildDirectionButton(
                direction: 'left',
                icon: Icons.keyboard_arrow_left,
                command: 'L',
              ),
            ),

            // Bouton Droite
            Positioned(
              right: 15,
              child: _buildDirectionButton(
                direction: 'right',
                icon: Icons.keyboard_arrow_right,
                command: 'R',
              ),
            ),

            // Bouton central STOP
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                _commandService.sendCommand('S');
                debugPrint('STOP');
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryGreen,
                      darkGreen,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentGreen.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: accentGreen.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton({
    required String direction,
    required IconData icon,
    required String command,
  }) {
    final bool isActive = _activeButton == direction;

    return GestureDetector(
      onTapDown: (_) => _onButtonPressed(direction, command),
      onTapUp: (_) => _onButtonReleased(),
      onTapCancel: _onButtonReleased,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: isActive ? 70 : 65,
        height: isActive ? 70 : 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? accentGreen : primaryGreen,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: accentGreen.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
              : [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
          border: Border.all(
            color: isActive ? Colors.white : accentGreen.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isActive ? 45 : 40,
        ),
      ),
    );
  }

  Widget _buildSpeedSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VITESSE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentGreen.withOpacity(0.5)),
                ),
                child: Text(
                  '${_speed.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accentGreen,
              inactiveTrackColor: primaryGreen.withOpacity(0.3),
              thumbColor: accentGreen,
              overlayColor: accentGreen.withOpacity(0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _speed,
              min: 50,
              max: 255,
              onChanged: (value) {
                setState(() => _speed = value);
                if (value.toInt() % 25 == 0) {
                  HapticFeedback.selectionClick();
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('50', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
              Text('LENT', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
              Text('MOYEN', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
              Text('RAPIDE', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
              Text('255', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton Klaxon
          _buildActionButton(
            icon: Icons.volume_up,
            label: 'KLAXON',
            onTap: () {
              HapticFeedback.heavyImpact();
              _commandService.sendCommand('H');
              debugPrint('Klaxon');
            },
          ),

          // Bouton Phares
          _buildActionButton(
            icon: lightsOn ? Icons.lightbulb : Icons.lightbulb_outline,
            label: 'PHARES',
            isActive: lightsOn,
            onTap: () {
              setState(() => lightsOn = !lightsOn);
              HapticFeedback.mediumImpact();
              _commandService.sendCommand(lightsOn ? 'LON' : 'LOFF');
              debugPrint('Phares: ${lightsOn ? "ON" : "OFF"}');
            },
          ),

          // Bouton d'urgence
          _buildActionButton(
            icon: Icons.warning_amber,
            label: 'URGENCE',
            color: Colors.red,
            onTap: () {
              HapticFeedback.heavyImpact();
              _commandService.sendCommand('S');
              setState(() => _speed = 50);
              debugPrint('ARRÊT D\'URGENCE');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    final buttonColor = color ?? (isActive ? accentGreen : primaryGreen);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: buttonColor.withOpacity(isActive ? 0.8 : 0.6),
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: isActive ? Colors.white : buttonColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryGreen.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: Icon(
              isJoystickMode ? Icons.gamepad : Icons.touch_app,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              setState(() => isJoystickMode = !isJoystickMode);
              HapticFeedback.selectionClick();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
            onPressed: () => debugPrint('Settings'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Painter pour dessiner une grille subtile en fond
class GridPainter extends CustomPainter {
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
