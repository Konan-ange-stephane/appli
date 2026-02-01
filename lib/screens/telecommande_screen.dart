import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telecommande/models/device_info.dart';
import 'package:telecommande/services/command_service.dart';

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
  static const Color accentGreen = Color(0xFF2ECC71);

  void _onButtonPressed(String direction, String command) {
    HapticFeedback.mediumImpact();
    setState(() => _activeButton = direction);
    _commandService.sendCommand(command);
    debugPrint('$direction - Commande: $command');
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
            // Fond grille
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(),
            ),
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildIndicators(),
                        const SizedBox(height: 15),
                        _buildDirectionalPad(),
                        const SizedBox(height: 20),
                        _buildSpeedSlider(),
                        const SizedBox(height: 15),
                        _buildActionButtons(),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          const Text(
            'TÉLÉCOMMANDE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          Row(
            children: [
              // Refresh button
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  onPressed: _refreshDevices,
                ),
              ),
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
        ],
      ),
    );
  }

  /// Indicateurs Bluetooth, batterie, signal
  Widget _buildIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIndicator(
            icon: Icons.bluetooth,
            label: isConnected ? 'Connecté' : 'Déconnecté',
            isActive: isConnected,
            onTap: _onBluetoothTap,
          ),
          _buildIndicator(
            icon: Icons.battery_full,
            label: '85%',
            isActive: true,
          ),
          _buildIndicator(
            icon: Icons.signal_cellular_alt,
            label: 'Fort',
            isActive: true,
          ),
        ],
      ),
    );
  }

  void _onBluetoothTap() async {
    if (isConnected) {
      await _commandService.disconnect();
      setState(() => isConnected = false);
      HapticFeedback.lightImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déconnecté de l\'Arduino'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Vérifie si le Bluetooth est activé
    final bluetoothEnabled = await _commandService.isBluetoothEnabled();
    if (!bluetoothEnabled) {
      if (mounted) {
        final enable = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Bluetooth désactivé'),
            content: const Text('Voulez-vous activer Bluetooth ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Activer'),
              ),
            ],
          ),
        );

        if (enable == true) {
          await _commandService.turnOnBluetooth();
          await Future.delayed(const Duration(seconds: 2));
        } else {
          return;
        }
      }
    }

    // Affiche le dialogue de scan
    // Vérifie que le service localisation est activé sur Android (nécessaire au scan BLE)
    final locationEnabled = await _commandService.isLocationServiceEnabled();
    if (!locationEnabled) {
      if (mounted) {
        final open = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Localisation désactivée'),
            content: const Text('La localisation doit être activée pour scanner les périphériques Bluetooth. Voulez-vous ouvrir les paramètres ?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ouvrir')),
            ],
          ),
        );
        if (open == true) {
          await openAppSettings();
          return;
        } else {
          return;
        }
      }
    }

    final devices = await _commandService.scanDevices();
    if (!mounted) return;

    final selectedDevice = await showDialog<DeviceInfo>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Sélectionnez un appareil'),
        children: devices
            .map(
              (d) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, d),
                child: Text((d.name.isNotEmpty) ? d.name : d.id),
              ),
            )
            .toList(),
      ),
    );

    if (selectedDevice != null) {
      final connected = await _commandService.connect(selectedDevice);
      if (!mounted) return;
      setState(() => isConnected = connected);

      final deviceName = (selectedDevice.name.isNotEmpty) ? selectedDevice.name : selectedDevice.id;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              connected ? 'Connecté à $deviceName' : 'Échec de connexion à $deviceName'),
          backgroundColor: connected ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _refreshDevices() async {
    HapticFeedback.lightImpact();
    final locationEnabled = await _commandService.isLocationServiceEnabled();
    if (!locationEnabled) {
      if (mounted) {
        final open = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Localisation désactivée'),
            content: const Text('La localisation doit être activée pour scanner les périphériques Bluetooth. Voulez-vous ouvrir les paramètres ?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ouvrir')),
            ],
          ),
        );
        if (open == true) {
          await openAppSettings();
          return;
        } else {
          return;
        }
      }
    }

    final devices = await _commandService.scanDevices();
    if (!mounted) return;

    if (devices.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun appareil trouvé'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final selectedDevice = await showDialog<DeviceInfo>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Sélectionnez un appareil'),
        children: devices
            .map(
              (d) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, d),
                child: Text((d.name.isNotEmpty) ? d.name : d.id),
              ),
            )
            .toList(),
      ),
    );

    if (selectedDevice != null) {
      final connected = await _commandService.connect(selectedDevice);
      if (!mounted) return;
      setState(() => isConnected = connected);

      final deviceName = (selectedDevice.name.isNotEmpty) ? selectedDevice.name : selectedDevice.id;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(connected ? 'Connecté à $deviceName' : 'Échec de connexion à $deviceName'),
          backgroundColor: connected ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan terminé: ${devices.length} appareil(s) trouvé(s)')),
      );
    }
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
            Icon(icon, color: isActive ? accentGreen : Colors.grey, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// Pad directionnel
  Widget _buildDirectionalPad() {
    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cercle extérieur
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [primaryGreen.withOpacity(0.4), darkGreen.withOpacity(0.2), Colors.transparent],
                  stops: const [0.3, 0.7, 1.0],
                ),
                boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
              ),
            ),
            // Cercle intermédiaire
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryGreen.withOpacity(0.4), width: 2),
              ),
            ),
            // Boutons directionnels
            Positioned(top: 15, child: _buildDirectionButton('up', Icons.keyboard_arrow_up, 'A')),
            Positioned(bottom: 15, child: _buildDirectionButton('down', Icons.keyboard_arrow_down, 'R')),
            Positioned(left: 15, child: _buildDirectionButton('left', Icons.keyboard_arrow_left, 'G')),
            Positioned(right: 15, child: _buildDirectionButton('right', Icons.keyboard_arrow_right, 'D')),
            // Bouton STOP
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                _commandService.sendCommand('S');
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [primaryGreen, darkGreen]),
                  boxShadow: [BoxShadow(color: accentGreen.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
                  border: Border.all(color: accentGreen.withOpacity(0.5), width: 2),
                ),
                child: const Center(child: Icon(Icons.power_settings_new, color: Colors.white, size: 40)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton(String direction, IconData icon, String command) {
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
              ? [BoxShadow(color: accentGreen.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)]
              : [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
          border: Border.all(color: isActive ? Colors.white : accentGreen.withOpacity(0.3), width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: isActive ? 45 : 40),
      ),
    );
  }

  /// Slider de vitesse
  Widget _buildSpeedSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('VITESSE', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentGreen.withOpacity(0.5)),
                ),
                child: Text('${_speed.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: _speed,
            min: 50,
            max: 255,
            activeColor: accentGreen,
            inactiveColor: primaryGreen.withOpacity(0.3),
            onChanged: (value) => setState(() => _speed = value),
          ),
        ],
      ),
    );
  }

  /// Boutons actions
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.volume_up, 'KLAXON', () => _commandService.sendCommand('H')),
          _buildActionButton(
            lightsOn ? Icons.lightbulb : Icons.lightbulb_outline,
            'PHARES',
            () {
              setState(() => lightsOn = !lightsOn);
              _commandService.sendCommand(lightsOn ? 'LON' : 'LOFF');
            },
          ),
          _buildActionButton(Icons.warning_amber, 'URGENCE', () {
            _commandService.sendCommand('S');
            setState(() => _speed = 50);
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final buttonColor = color ?? primaryGreen;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: buttonColor.withOpacity(0.6),
              boxShadow: [BoxShadow(color: buttonColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
              border: Border.all(color: buttonColor.withOpacity(0.5), width: 2),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
        ],
      ),
    );
  }

  /// Bottom bar
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
          ),
          IconButton(
            icon: Icon(isJoystickMode ? Icons.gamepad : Icons.touch_app, color: Colors.white, size: 24),
            onPressed: () => setState(() => isJoystickMode = !isJoystickMode),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
            onPressed: () => debugPrint('Settings'),
          ),
        ],
      ),
    );
  }
}

/// Grille subtile en fond
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A4D21).withOpacity(0.1)
      ..strokeWidth = 0.5;
    const spacing = 30.0;
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
