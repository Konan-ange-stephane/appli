import 'package:flutter/foundation.dart';
import 'package:telecommande/services/bluetooth_service.dart';
import 'package:telecommande/models/device_info.dart';

/// Service centralisé pour l'envoi de commandes via Bluetooth vers l'Arduino
/// 
/// Commandes disponibles selon le protocole Arduino :
/// - A → avancer (Avancer)
/// - R → reculer (Reculer)
/// - G → gauche (Gauche)
/// - D → droite (Droite)
/// - S → stop
class CommandService {
  final BluetoothService _bluetoothService = BluetoothService();

  /// Envoie une commande via Bluetooth vers l'Arduino
  /// L'Arduino attend un seul caractère: A, R, G, D, ou S
  Future<void> sendCommand(String command) async {
    if (!_bluetoothService.isConnected) {
      debugPrint('Bluetooth non connecté. Veuillez vous connecter d\'abord.');
      return;
    }

    // Envoie uniquement le premier caractère (A, R, G, D, ou S)
    final char = command.isNotEmpty ? command[0] : 'S';
    await _bluetoothService.send(char);
  }

  /// Initialise la connexion Bluetooth avec l'Arduino
  Future<bool> connect(DeviceInfo device) async {
    return await _bluetoothService.connect(device);
  }

  /// Déconnecte l'appareil Bluetooth
  Future<void> disconnect() async {
    await _bluetoothService.disconnect();
  }

  /// Vérifie si le service est connecté
  bool get isConnected => _bluetoothService.isConnected;

  /// Recherche les appareils Bluetooth disponibles
  Future<List<DeviceInfo>> scanDevices({Duration timeout = const Duration(seconds: 10)}) async {
    return await _bluetoothService.scanDevices(timeout: timeout);
  }

  /// Vérifie si Bluetooth est activé
  Future<bool> isBluetoothEnabled() async {
    return await _bluetoothService.isBluetoothEnabled();
  }

  /// Vérifie si le service localisation est activé (Android BLE requirement)
  Future<bool> isLocationServiceEnabled() async {
    return await _bluetoothService.isLocationServiceEnabled();
  }

  /// Active Bluetooth
  Future<void> turnOnBluetooth() async {
    await _bluetoothService.turnOnBluetooth();
  }

  /// Obtient l'appareil connecté (BLE si applicable)
  // Retourne null pour Classic
  dynamic get connectedDevice => _bluetoothService.connectedDevice;

  /// Écoute les changements de connexion (BLE), sinon émission d'un `null` pour Classic
  Stream<dynamic> get connectionState {
    return _bluetoothService.connectionState;
  }
}

