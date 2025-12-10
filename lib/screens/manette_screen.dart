import 'package:flutter/material.dart';
import 'package:telecommande/services/command_service.dart';
import 'package:telecommande/widgets/direction_button.dart';
import 'package:telecommande/widgets/speed_slider.dart';
import 'package:telecommande/widgets/stop_button.dart';

/// Écran du Mode Manette avec boutons directionnels, slider de vitesse et bouton STOP
class ManetteScreen extends StatefulWidget {
  const ManetteScreen({super.key});

  @override
  State<ManetteScreen> createState() => _ManetteScreenState();
}

class _ManetteScreenState extends State<ManetteScreen> {
  final CommandService _commandService = CommandService();
  double _speed = 150.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Manette'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton Avant
          DirectionButton(
            label: 'Avant',
            icon: Icons.arrow_upward,
            onPressed: () {
              _commandService.sendCommand('F:${_speed.toInt()}');
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton Gauche
              DirectionButton(
                label: 'Gauche',
                icon: Icons.arrow_back,
                onPressed: () {
                  _commandService.sendCommand('L:${_speed.toInt()}');
                },
              ),
              const SizedBox(width: 40),
              // Bouton Droite
              DirectionButton(
                label: 'Droite',
                icon: Icons.arrow_forward,
                onPressed: () {
                  _commandService.sendCommand('R:${_speed.toInt()}');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bouton Arrière
          DirectionButton(
            label: 'Arrière',
            icon: Icons.arrow_downward,
            onPressed: () {
              _commandService.sendCommand('B:${_speed.toInt()}');
            },
          ),
          const SizedBox(height: 40),
          // Slider de vitesse
          SpeedSlider(
            value: _speed,
            onChanged: (value) {
              setState(() {
                _speed = value;
              });
            },
          ),
          const SizedBox(height: 40),
          // Bouton STOP
          StopButton(
            onPressed: () {
              _commandService.sendCommand('S');
            },
          ),
        ],
      ),
    );
  }
}

