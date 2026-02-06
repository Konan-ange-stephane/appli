import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ManetteScreen(),
  ));
}

class ManetteScreen extends StatefulWidget {
  const ManetteScreen({super.key});

  @override
  State<ManetteScreen> createState() => _ManetteScreenState();
}

class _ManetteScreenState extends State<ManetteScreen>
    with SingleTickerProviderStateMixin {
  bool powerOn = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0.85, end: 1.0).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _controller.reverse();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateButton(VoidCallback action) {
    _controller.forward();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final controlSize = screenWidth * 0.4;
    const symbolIconSize = 24.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "MANETTE",
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F2F24),
        selectedItemColor: const Color(0xFF6ED9A0),
        unselectedItemColor: Colors.white70,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.gamepad, size: 24), label: 'Mode'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 24), label: 'Settings'),
        ],
      ),
      body: Stack(
        children: [
          // Left Circle
          Positioned(
            left: screenWidth * 0.1,
            bottom: screenHeight * 0.18,
            child: _buildCircularControl(
              size: controlSize,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton('F', controlSize * 0.44),
                  Container(
                    height: 1,
                    width: controlSize * 0.36,
                    color: const Color(0xFF1A4D21),
                  ),
                  _buildControlButton('B', controlSize * 0.44),
                ],
              ),
            ),
          ),

          // Right Circle
          Positioned(
            right: screenWidth * 0.1,
            bottom: screenHeight * 0.18,
            child: _buildCircularControl(
              size: controlSize,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton('G', controlSize * 0.44),
                  Container(
                    width: 1,
                    height: controlSize * 0.36,
                    color: const Color(0xFF1A4D21),
                  ),
                  _buildControlButton('R', controlSize * 0.44),
                ],
              ),
            ),
          ),

          // POWER BUTTON — Vert/Rouge
          Positioned(
            left: screenWidth / 2 - (symbolIconSize + 20) / 2,
            bottom: screenHeight * 0.18 + controlSize / 2 - (symbolIconSize + 20) / 2,
            child: ScaleTransition(
              scale: _animation,
              child: _buildSymbolButton(
                icon: Icons.power_settings_new,
                iconSize: symbolIconSize,
                active: powerOn,
                onTap: () => _animateButton(() {
                  setState(() => powerOn = !powerOn);
                  debugPrint(powerOn ? 'Power ON' : 'Power OFF');
                }),
              ),
            ),
          ),

          // Horn — Gris avec nuances de vert
          Positioned(
            left: screenWidth * 0.1 + controlSize / 2 - symbolIconSize / 2,
            bottom: screenHeight * 0.18 - symbolIconSize - 10,
            child: _buildSymbolButtonStatic(
              icon: Icons.volume_up,
              iconSize: symbolIconSize,
            ),
          ),

          // Headlight — Gris avec nuances de vert
          Positioned(
            right: screenWidth * 0.1 + controlSize / 2 - symbolIconSize / 2,
            bottom: screenHeight * 0.18 - symbolIconSize - 10,
            child: _buildSymbolButtonStatic(
              icon: Icons.lightbulb,
              iconSize: symbolIconSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularControl({required double size, required Widget child}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF1A4D21).withOpacity(0.6),
            const Color(0xFF183E1D).withOpacity(0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: child,
    );
  }

  Widget _buildControlButton(String text, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  // Boutons Power (avec état)
  Widget _buildSymbolButton({
    required IconData icon,
    required double iconSize,
    VoidCallback? onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: iconSize + 20,
        height: iconSize + 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? Colors.green : Colors.red,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }

  // Boutons phare  et claxon  (gris/vert)
  Widget _buildSymbolButtonStatic({
    required IconData icon,
    required double iconSize,
  }) {
    return Container(
      width: iconSize + 20,
      height: iconSize + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.grey[700]!,
            Colors.green.withOpacity(0.4),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }
}
