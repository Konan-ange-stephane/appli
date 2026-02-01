import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telecommande/models/device_info.dart';

/// Service pour la communication Bluetooth avec l'Arduino
class BluetoothService {
  // BLE
  blue.BluetoothDevice? _connectedBleDevice;
  blue.BluetoothCharacteristic? _writeCharacteristic;

  // Classic (RFCOMM) - Android HC-05 via platform channel
  final MethodChannel _platform = const MethodChannel('telecommande/classic_bt');
  String? _classicAddress;
  bool _classicConnected = false;
  // Placeholders for classic connection objects (platform-specific)
  dynamic _classicConnection;
  dynamic _classicDevice;
  // Generic pointer to the connected BLE device (used in some debug paths)
  blue.BluetoothDevice? _connectedDevice;

  bool _isConnected = false;
  bool _isScanning = false;
  bool _useLinuxWorkaround = false;

  /// Vérifie si Bluetooth est activé
  Future<bool> isBluetoothEnabled() async {
    try {
      if (!await blue.FlutterBluePlus.isSupported) {
        return false;
      }
      
      // Obtient l'état actuel du Bluetooth
      final state = await blue.FlutterBluePlus.adapterState.first;
      return state == blue.BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('Erreur vérification Bluetooth: $e');
      return false;
    }
  }

  /// Active Bluetooth si désactivé
  Future<void> turnOnBluetooth() async {
    try {
      if (await blue.FlutterBluePlus.isSupported) {
        await blue.FlutterBluePlus.turnOn();
      }
    } catch (e) {
      debugPrint('Erreur activation Bluetooth: $e');
    }
  }

  /// Recherche les appareils Bluetooth disponibles
  /// Retourne une liste de `DeviceInfo` contenant les appareils BLE et Classic
  Future<List<DeviceInfo>> scanDevices({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      final List<DeviceInfo> devices = [];

      // BLE scan
      try {
        if (await blue.FlutterBluePlus.isAvailable || await blue.FlutterBluePlus.isSupported) {
          // Request required runtime permissions on Android
          if (Platform.isAndroid) {
            try {
              await [
                Permission.bluetoothScan,
                Permission.bluetoothConnect,
                Permission.location,
                Permission.locationWhenInUse,
              ].request();
            } catch (e) {
              debugPrint('Erreur demande permissions Bluetooth: $e');
            }
          }

          if (_isScanning) await blue.FlutterBluePlus.stopScan();
          _isScanning = true;
          final Set<String> seen = {};
          final subscription = blue.FlutterBluePlus.scanResults.listen((results) {
            for (var result in results) {
              final d = result.device;
              final id = d.id.id;
              if (!seen.contains(id)) {
                seen.add(id);
                devices.add(DeviceInfo(name: d.name ?? '', id: id, isClassic: false, nativeDevice: d));
                debugPrint('BLE trouvé: ${d.name} ($id)');
              }
            }
          });
          await blue.FlutterBluePlus.startScan(timeout: timeout);
          await Future.delayed(timeout);
          await blue.FlutterBluePlus.stopScan();
          await subscription.cancel();
          _isScanning = false;
        }
      } catch (e) {
        debugPrint('Erreur scan BLE: $e');
        _isScanning = false;
      }

      // Classic scan on Android (bonded devices via platform channel)
      if (Platform.isAndroid) {
        try {
          final List<dynamic>? bonded = await MethodChannel('telecommande/classic_bt').invokeMethod('getBondedDevices');
          if (bonded != null) {
            for (var b in bonded) {
              final name = b['name'] as String? ?? '';
              final addr = b['address'] as String? ?? '';
              if (!devices.any((x) => x.id == addr)) {
                devices.add(DeviceInfo(name: name, id: addr, isClassic: true, nativeDevice: null));
                debugPrint('Classic (bonded) trouvé: $name ($addr)');
              }
            }
          }
        } catch (e) {
          debugPrint('Erreur discovery classic (platform): $e');
        }
      }

      debugPrint('Scan terminé: ${devices.length} appareil(s) trouvé(s)');
      return devices;
    } catch (e) {
      debugPrint('Erreur scan Bluetooth: $e');
      _isScanning = false;
      return [];
    }
  }

  /// Vérifie si le service de localisation est activé (nécessaire pour BLE scan sur Android)
  Future<bool> isLocationServiceEnabled() async {
    if (!Platform.isAndroid) return true;
    try {
      final status = await Permission.location.serviceStatus;
      return status == ServiceStatus.enabled;
    } catch (e) {
      debugPrint('Erreur vérification service localisation: $e');
      return false;
    }
  }

  /// Se connecte à un appareil Bluetooth (version améliorée)
  /// Prend un `DeviceInfo` (BLE ou Classic)
  Future<bool> connect(DeviceInfo deviceInfo) async {
    try {
      // Déconnecte si déjà connecté
      if (_isConnected) await disconnect();

      debugPrint('Tentative de connexion à: ${deviceInfo.name} (${deviceInfo.id})');

      // Classic (Android) via platform channel
      if (deviceInfo.isClassic && Platform.isAndroid) {
        try {
          debugPrint('Tentative connexion RFCOMM (Classic) à ${deviceInfo.id} via platform');
          final ok = await _platform.invokeMethod<bool>('connect', {'address': deviceInfo.id});
          _classicAddress = deviceInfo.id;
          _classicConnected = ok == true;
          _isConnected = _classicConnected;
          debugPrint('Classic connecté (platform): $_isConnected');
          return _isConnected;
        } catch (e) {
          debugPrint('Erreur connexion Classic (platform): $e');
          _isConnected = false;
          return false;
        }
      }

      // BLE path
      final device = deviceInfo.nativeDevice as blue.BluetoothDevice;

      // Pour Linux, appliquer un workaround spécifique
      if (Platform.isLinux) {
        _useLinuxWorkaround = true;
        debugPrint('Mode Linux activé - utilisation du workaround SPP');
      }

      // Vérifie l'état de l'appareil avant de se connecter
      try {
        final connectionState = await device.connectionState.first.timeout(
          const Duration(seconds: 2),
          onTimeout: () => blue.BluetoothConnectionState.disconnected,
        );
        debugPrint('État de connexion actuel: $connectionState');
      } catch (e) {
        debugPrint('Impossible de vérifier l\'état de connexion: $e');
      }

      // Se connecte à l'appareil - essaie plusieurs stratégies
      bool connected = false;
      Exception? lastError;
      
      // STRATÉGIE SPÉCIFIQUE POUR LINUX/HC-05
      if (Platform.isLinux) {
        debugPrint('Tentative avec paramètres optimisés pour Linux/HC-05...');
        try {
          await device.connect(
            timeout: const Duration(seconds: 20),
            autoConnect: false,
            mtu: null, // IMPORTANT: null pour éviter les conflits avec autoConnect
            license: blue.License.free,
          );
          connected = true;
          debugPrint('Connexion Linux réussie');
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          debugPrint('Échec connexion Linux: $e');
        }
      }
      
      // STRATÉGIE GÉNÉRALE (si Linux échoue ou pour autres plateformes)
      if (!connected) {
        // Stratégie 1: Connexion normale avec autoConnect: false
        try {
          await device.connect(
            timeout: const Duration(seconds: 15),
            autoConnect: false,
            license: blue.License.free,
          );
          connected = true;
          debugPrint('Connexion réussie avec autoConnect: false');
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          debugPrint('Tentative 1 échouée: $e');
          
          // Stratégie 2: Si erreur profil BR, essaie avec autoConnect: true
          if (e.toString().contains('br-connection-profile') || 
              e.toString().contains('NotAvailable')) {
            debugPrint('Erreur profil BR détectée, tentative avec autoConnect: true');
            await Future.delayed(const Duration(milliseconds: 500));
            try {
              await device.connect(
                timeout: const Duration(seconds: 15),
                autoConnect: true,
                license: blue.License.free,
              );
              connected = true;
              debugPrint('Connexion réussie avec autoConnect: true');
            } catch (e2) {
              lastError = e2 is Exception ? e2 : Exception(e2.toString());
              debugPrint('Tentative 2 échouée: $e2');
            }
          }
          
          // Stratégie 3: Si toujours échoué, réessaie avec timeout plus long
          if (!connected) {
            debugPrint('Tentative avec timeout plus long...');
            await Future.delayed(const Duration(milliseconds: 1000));
            try {
              await device.connect(
                timeout: const Duration(seconds: 30),
                autoConnect: false,
                license: blue.License.free,
              );
              connected = true;
              debugPrint('Connexion réussie avec timeout étendu');
            } catch (e3) {
              lastError = e3 is Exception ? e3 : Exception(e3.toString());
              debugPrint('Tentative 3 échouée: $e3');
            }
          }
        }
      }
      
      if (!connected) {
        throw lastError ?? Exception('Échec de toutes les tentatives de connexion');
      }

      debugPrint('Connexion établie, découverte des services...');

      // Attend un peu pour que la connexion soit stable
      await Future.delayed(const Duration(milliseconds: 1000));

      // Découvre les services avec plus de patience pour Linux
      List<blue.BluetoothService> services;
      try {
        services = await device.discoverServices();
      } catch (e) {
        debugPrint('Erreur découverte services: $e, réessai...');
        await Future.delayed(const Duration(seconds: 1));
        services = await device.discoverServices();
      }
      
      debugPrint('Services trouvés: ${services.length}');

      // Affiche tous les services pour le débogage
      for (var service in services) {
        debugPrint('Service UUID: ${service.uuid}');
        for (var char in service.characteristics) {
          debugPrint('  - Caractéristique: ${char.uuid}, write: ${char.properties.write}, writeWithoutResponse: ${char.properties.writeWithoutResponse}');
        }
      }

      // Cherche le service Serial - UUIDs communs pour HC-05
      blue.BluetoothService? serialService;
      
      // UUIDs spécifiques pour HC-05 et modules similaires
      final List<String> sppUuids = [
        '00001101-0000-1000-8000-00805f9b34fb', // SPP standard
        '00001101-0000-1000-8000-00805F9B34FB',
        'ffe0', // Service personnalisé commun
        'ff00', // Autre service commun
      ];
      
      for (var service in services) {
        final uuidStr = service.uuid.toString().toLowerCase();
        for (var targetUuid in sppUuids) {
          if (uuidStr.contains(targetUuid.toLowerCase().replaceAll('-', ''))) {
            serialService = service;
            debugPrint('Service Serial trouvé (${service.uuid}) pour HC-05');
            break;
          }
        }
        if (serialService != null) break;
      }

      // Si pas de service Serial trouvé, essaie le premier service disponible
      if (serialService == null && services.isNotEmpty) {
        debugPrint('Service Serial standard non trouvé, utilisation du premier service disponible');
        serialService = services.first;
      }

      if (serialService == null) {
        throw Exception('Aucun service trouvé sur l\'appareil');
      }

      // Cherche la caractéristique d'écriture
      _writeCharacteristic = null;
      
      // Essaie d'abord dans le service sélectionné
      for (var characteristic in serialService.characteristics) {
        if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
          _writeCharacteristic = characteristic;
          debugPrint('Caractéristique d\'écriture trouvée: ${characteristic.uuid}');
          break;
        }
      }

      // Si pas trouvé, cherche dans tous les services
      if (_writeCharacteristic == null) {
        debugPrint('Recherche dans tous les services...');
        for (var service in services) {
          for (var characteristic in service.characteristics) {
            if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
              _writeCharacteristic = characteristic;
              debugPrint('Caractéristique d\'écriture trouvée dans service ${service.uuid}: ${characteristic.uuid}');
              break;
            }
          }
          if (_writeCharacteristic != null) break;
        }
      }

      if (_writeCharacteristic == null) {
        // Pour Linux/HC-05, on peut quand même tenter sans caractéristique
        if (Platform.isLinux) {
          debugPrint('ATTENTION: Aucune caractéristique d\'écriture trouvée, mais continuation en mode Linux');
        } else {
          throw Exception('Aucune caractéristique d\'écriture trouvée');
        }
      }

      _connectedBleDevice = device;
      _connectedDevice = device;
      _isConnected = true;
      debugPrint('Connexion Bluetooth réussie!');
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      debugPrint('Erreur connexion Bluetooth: $e');
      
      // Messages d'erreur plus explicites
      if (errorMessage.contains('br-connection-profile') || 
          errorMessage.contains('NotAvailable')) {
        debugPrint('ERREUR: Le profil Bluetooth Classic (BR/EDR) n\'est pas disponible.');
        debugPrint('SOLUTIONS POSSIBLES:');
        debugPrint('1. Vérifiez que le module HC-05 est correctement appairé avec votre appareil');
        debugPrint('2. Oubliez et réappairez le module dans les paramètres Bluetooth');
        debugPrint('3. Vérifiez que le module est en mode appairable (LED clignotante)');
        debugPrint('4. Redémarrez le Bluetooth de votre appareil');
        
        // Solution spécifique Linux
        if (Platform.isLinux) {
          debugPrint('5. LINUX: Exécutez: sudo rfcomm connect 0 ${_connectedDevice?.remoteId} 1');
          debugPrint('6. LINUX: Puis utilisez le port /dev/rfcomm0');
        }
      } else if (errorMessage.contains('timeout')) {
        debugPrint('ERREUR: Timeout de connexion. Le module peut être occupé ou hors de portée.');
      } else if (errorMessage.contains('permission')) {
        debugPrint('ERREUR: Permissions Bluetooth manquantes.');
      }
      
      _isConnected = false;
      _connectedBleDevice = null;
      _writeCharacteristic = null;
      _useLinuxWorkaround = false;
      
      // Déconnecte en cas d'erreur
      try {
        if (!deviceInfo.isClassic) {
          if (await (deviceInfo.nativeDevice as blue.BluetoothDevice).connectionState.first.timeout(
            const Duration(seconds: 1),
            onTimeout: () => blue.BluetoothConnectionState.disconnected,
          ) == blue.BluetoothConnectionState.connected) {
            await (deviceInfo.nativeDevice as blue.BluetoothDevice).disconnect();
          }
        } else {
          try {
            await _classicConnection?.close();
          } catch (_) {}
        }
      } catch (_) {}
      
      return false;
    }
  }

  /// Envoie une commande via Bluetooth (version améliorée)
  Future<void> send(String command) async {
    if (!_isConnected) {
      debugPrint('Bluetooth non connecté - impossible d\'envoyer: $command');
      return;
    }

    // Envoi via Classic (RFCOMM)
    try {
      final data = Uint8List.fromList(command.codeUnits);
      if (_classicConnection != null && _classicConnection!.isConnected) {
        _classicConnection!.output.add(data);
        await _classicConnection!.output.allSent;
        debugPrint('Commande envoyée via Classic RFCOMM: $command');
        return;
      }

      // BLE envoi
      if (_writeCharacteristic != null) {
        if (_writeCharacteristic!.properties.write) {
          await _writeCharacteristic!.write(data, withoutResponse: false);
        } else if (_writeCharacteristic!.properties.writeWithoutResponse) {
          await _writeCharacteristic!.write(data, withoutResponse: true);
        } else {
          debugPrint('Caractéristique ne supporte pas l\'écriture');
          throw Exception('Caractéristique en écriture non supportée');
        }
      } else if (_useLinuxWorkaround && Platform.isLinux) {
        debugPrint('Mode Linux workaround - tentative via RFCOMM');
        await _sendViaLinuxWorkaround(command);
      } else {
        debugPrint('Aucune méthode d\'envoi disponible');
        return;
      }

      debugPrint('Commande envoyée via Bluetooth: $command');
    } catch (e) {
      debugPrint('Erreur envoi Bluetooth: $e');
      _isConnected = false;
      if (Platform.isLinux) {
        debugPrint('SOLUTION ALTERNATIVE LINUX:');
        debugPrint('1. Ouvrez un terminal');
        debugPrint('2. Exécutez: echo "$command" | sudo tee /dev/rfcomm0');
      }
    }
  }

  /// Méthode de secours pour Linux via RFCOMM
  Future<void> _sendViaLinuxWorkaround(String command) async {
    if (!Platform.isLinux) return;
    
    try {
      final process = await Process.start('echo', ['$command\n']);
      final sink = process.stdin;
      sink.write('$command\n');
      await sink.flush();
      await sink.close();
      
      // Rediriger vers rfcomm0
      final file = File('/dev/rfcomm0');
      if (await file.exists()) {
        await file.writeAsString('$command\n', mode: FileMode.append);
        debugPrint('Commande envoyée via RFCOMM workaround: $command');
      } else {
        debugPrint('/dev/rfcomm0 non disponible');
      }
    } catch (e) {
      debugPrint('Erreur workaround Linux: $e');
    }
  }

  /// Vérifie si le service est connecté
  bool get isConnected => _isConnected;

  /// Obtient l'appareil connecté (BLE) si applicable
  blue.BluetoothDevice? get connectedDevice => _connectedBleDevice;

  /// Déconnecte l'appareil Bluetooth
  Future<void> disconnect() async {
    try {
      if (_classicConnection != null) {
        await _classicConnection?.finish();
        _classicConnection = null;
        _classicDevice = null;
      }
      if (_connectedBleDevice != null) {
        try {
          await _connectedBleDevice!.disconnect();
        } catch (_) {}
        _connectedBleDevice = null;
      }
      _isConnected = false;
      _writeCharacteristic = null;
      _useLinuxWorkaround = false;
      debugPrint('Déconnecté avec succès');
    } catch (e) {
      debugPrint('Erreur déconnexion Bluetooth: $e');
    }
  }

  /// Écoute les changements de connexion
  Stream<blue.BluetoothConnectionState> get connectionState {
    if (_connectedBleDevice == null) {
      return Stream.value(blue.BluetoothConnectionState.disconnected);
    }
    return _connectedBleDevice!.connectionState;
  }

  /// Méthode utilitaire pour afficher les infos de débogage
  void printDebugInfo() {
    debugPrint('=== DEBUG BLUETOOTH ===');
    debugPrint('Connecté: $_isConnected');
    debugPrint('BLE Appareil: ${_connectedBleDevice?.name} (${_connectedBleDevice?.id})');
    debugPrint('Classic Appareil: ${_classicDevice?.name} (${_classicDevice?.address})');
    debugPrint('Caractéristique: ${_writeCharacteristic?.uuid}');
    debugPrint('Mode Linux: $_useLinuxWorkaround');
    debugPrint('Platforme: ${Platform.operatingSystem}');
    debugPrint('=======================');
  }
}