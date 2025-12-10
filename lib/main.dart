import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ControlInterface(),
    );
  }
}

class ControlInterface extends StatelessWidget {
  const ControlInterface({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top bar with icons
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left icons
                  Row(
                    children: [
                      _buildTopIcon(Icons.rectangle_outlined),
                      const SizedBox(width: 20),
                      _buildTopIcon(Icons.lightbulb_outline),
                      const SizedBox(width: 20),
                      _buildTopIcon(Icons.local_parking),
                      const SizedBox(width: 20),
                      _buildTopIcon(Icons.warning_amber_outlined),
                      const SizedBox(width: 20),
                      _buildTopIconWithS(),
                    ],
                  ),
                  // Right icons
                  Row(
                    children: [
                      _buildTopIcon(Icons.build_outlined),
                      const SizedBox(width: 20),
                      _buildTopIcon(Icons.menu),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Code icon top right
          Positioned(
            top: 110,
            right: 20,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1A4D21),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.code, color: Colors.white, size: 24),
            ),
          ),

          // Left control (Up/Down)
          Positioned(
            left: 80,
            bottom: 100,
            child: _buildCircularControl(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton('F', isTop: true),
                  Container(
                    height: 1,
                    width: 80,
                    color: const Color(0xFF1A4D21),
                  ),
                  _buildControlButton('B', isBottom: true),
                ],
              ),
            ),
          ),

          // Right control (Left/Right)
          Positioned(
            right: 80,
            bottom: 100,
            child: _buildCircularControl(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton('G', isLeft: true),
                  Container(
                    width: 1,
                    height: 80,
                    color: const Color(0xFF1A4D21),
                  ),
                  _buildControlButton('R', isRight: true),
                ],
              ),
            ),
          ),

          // Top center icons
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 100),
                _buildCenterIcon(Icons.speed_outlined),
                const SizedBox(width: 400),
                _buildCenterIcon(Icons.campaign),
              ],
            ),
          ),

          // Center icon
          Positioned(
            top: 340,
            left: 0,
            right: 0,
            child: Center(
              child: _buildCenterIcon(Icons.gps_fixed),
            ),
          ),

          // Bottom center arrow
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_up,
                color: Colors.white.withOpacity(0.5),
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, {bool hasInnerCircle = false, Widget? customChild}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1A4D21),
        shape: BoxShape.circle,
      ),
      child: customChild ??
          (hasInnerCircle
              ? Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          )
              : Icon(icon, color: Colors.white, size: 24)),
    );
  }

  Widget _buildTopIconWithS() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0D3A3A),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.circle, color: Colors.white, size: 30),
          const Text(
            'S',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterIcon(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1A4D21),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _buildCircularControl({required Widget child}) {
    return Container(
      width: 200,
      height: 200,
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

  Widget _buildControlButton(String text,
      {bool isTop = false, bool isBottom = false, bool isLeft = false, bool isRight = false}) {
    return Expanded(
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
}
