class DeviceInfo {
  final String name;
  final String id;
  final bool isClassic; // true = Classic (RFCOMM), false = BLE (GATT)
  final dynamic nativeDevice; // underlying object (flutter_blue_plus or flutter_bluetooth_serial)

  DeviceInfo({required this.name, required this.id, required this.isClassic, this.nativeDevice});

  @override
  String toString() => name.isNotEmpty ? name : id;
}
