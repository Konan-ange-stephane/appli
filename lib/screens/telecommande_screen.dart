import 'package:flutter/material.dart';
import 'package:telecommande/services/command_service.dart';

/// Écran du Mode Télécommande - Interface avec pad de direction circulaire
class TelecommandeScreen extends StatefulWidget {
  const TelecommandeScreen({super.key});

  @override
  State<TelecommandeScreen> createState() => _TelecommandeScreenState();
}

class _TelecommandeScreenState extends State<TelecommandeScreen> {
  final CommandService _commandService = CommandService();
  bool isJoystickMode = false; // État du switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            debugPrint('Menu cliqué !');
          },
        ),
        title: const Text(
          'Télécommande',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.error_outline, color: Colors.white),
            onPressed: () {
              debugPrint('Bouton ! cliqué');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grand cercle avec flèches
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade200,
                  ),
                ),
                // Flèche haut
                Positioned(
                  top: 30,
                  child: IconButton(
                    iconSize: 50,
                    icon: const Icon(Icons.arrow_drop_up, color: Colors.white),
                    onPressed: () {
                      _commandService.sendCommand('F:150');
                      debugPrint('Avancer');
                    },
                  ),
                ),
                // Flèche bas
                Positioned(
                  bottom: 30,
                  child: IconButton(
                    iconSize: 50,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    onPressed: () {
                      _commandService.sendCommand('B:150');
                      debugPrint('Reculer');
                    },
                  ),
                ),
                // Flèche gauche
                Positioned(
                  left: 30,
                  child: IconButton(
                    iconSize: 50,
                    icon: const Icon(Icons.arrow_left, color: Colors.white),
                    onPressed: () {
                      _commandService.sendCommand('L:150');
                      debugPrint('Gauche');
                    },
                  ),
                ),
                // Flèche droite
                Positioned(
                  right: 30,
                  child: IconButton(
                    iconSize: 50,
                    icon: const Icon(Icons.arrow_right, color: Colors.white),
                    onPressed: () {
                      _commandService.sendCommand('R:150');
                      debugPrint('Droite');
                    },
                  ),
                ),
                // bouton central ON/OFF
                Positioned(
                  child: GestureDetector(
                    onTap: () {
                      _commandService.sendCommand('S');
                      debugPrint('ON/OFF cliqué');
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.power_settings_new,
                            color: Colors.white, size: 40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Switch latéral style iPhone sous le bouton d'exclamation
          Positioned(
            top: 80,
            right: 16,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isJoystickMode = !isJoystickMode;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 30,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: isJoystickMode ? Colors.green : Colors.red,
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: isJoystickMode
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isJoystickMode ? 'Mode joystick' : 'Mode bouton',
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          ),

          // Bouton + positionné en bas à droite juste au-dessus de la barre de navigation
          Positioned(
            bottom: 70,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                debugPrint('Bouton + cliqué !');
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.blue,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  debugPrint('Settings cliqué !');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
