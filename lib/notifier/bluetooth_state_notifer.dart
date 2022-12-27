import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final bluetoothStateProvider = StreamProvider((ref) {
  return FlutterBluePlus.instance.state;
});

final bluetoothScanningProvider = StreamProvider((ref) {
  return FlutterBluePlus.instance.isScanning;
});

final bluetoothConnectedDeviceProvider = FutureProvider((ref) {
  return FlutterBluePlus.instance.connectedDevices;
});
