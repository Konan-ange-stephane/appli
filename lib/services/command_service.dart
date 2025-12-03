import 'package:telecommande/services/bluetooth_service.dart';

/// Service centralisé pour l'envoi de commandes via Bluetooth
/// 
/// Commandes disponibles :
/// - F:x → avancer (Forward)
/// - B:x → reculer (Backward)
/// - L:x → gauche (Left)
/// - R:x → droite (Right)
/// - S → stop
class CommandService {
  final BluetoothService _bluetoothService = BluetoothService();

  /// Envoie une commande via Bluetooth
  Future<void> sendCommand(String command) async {
    // TODO: Implémenter la logique d'envoi
    // Exemple: _bluetoothService.send(command)
  }
}

