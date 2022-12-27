import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sample_bluetooth_connect/notifier/bluetooth_state_notifer.dart';
import 'package:sample_bluetooth_connect/pages/device_detail_page.dart';

class DeviceScanPage extends ConsumerWidget {
  const DeviceScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bluetoothState = ref.watch(bluetoothStateProvider);
    final bluetoothScanning = ref.watch(bluetoothScanningProvider);
    final bluetoothScanResult = ref.watch(bluetoothScanResultProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Demo"),
        actions: [
          bluetoothState.value == BluetoothState.on
              ? const Icon(Icons.bluetooth_outlined)
              : const Icon(Icons.bluetooth_disabled_outlined),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0)),
        ],
      ),
      body: buildBody(bluetoothScanResult),
      floatingActionButton: buildFloatingActionButton(
        bluetoothState,
        bluetoothScanning,
      ),
    );
  }

  Widget buildBody(AsyncValue<List<ScanResult>> bluetoothScanResult) {
    if (!bluetoothScanResult.hasValue) {
      return const CircularProgressIndicator();
    } else if (bluetoothScanResult.value!.isEmpty) {
      return const Center(child: Text("Not Found Devices..."));
    } else {
      return ListView.builder(itemBuilder: (context, index) {
        final device = bluetoothScanResult.value![index].device;
        return Card(
          child: ListTile(
            title: Text(device.name),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DeviceDetailPage(device: device)));
            },
            trailing: StreamBuilder(
              stream: device.state,
              builder: (context, snapshot) {
                if (snapshot.data == BluetoothDeviceState.connected) {
                  return const Icon(
                    Icons.circle,
                    color: Colors.redAccent,
                  );
                } else {
                  return const Icon(
                    Icons.circle,
                    color: Colors.grey,
                  );
                }
              },
            ),
          ),
        );
      });
    }
  }

  FloatingActionButton buildFloatingActionButton(
      AsyncValue<BluetoothState> bluetoothState,
      AsyncValue<bool> bluetoothScanning) {
    return FloatingActionButton(
      onPressed: () async {
        // Bluetooth ON
        if (bluetoothState.value != BluetoothState.on) {
          await FlutterBluePlus.instance.turnOn();
          // Bluetoothが有効化されるまで少し待機
          await Future.delayed(const Duration(seconds: 2));
        }
        if (!bluetoothScanning.hasValue) return;
        if (bluetoothScanning.value!) {
          await FlutterBluePlus.instance.stopScan();
        } else {
          await FlutterBluePlus.instance
              .startScan(timeout: const Duration(seconds: 5));
        }
      },
      backgroundColor: bluetoothScanning.hasValue
          ? bluetoothScanning.value!
              ? Colors.redAccent
              : Colors.blue
          : Colors.grey,
      child: bluetoothScanning.hasValue
          ? bluetoothScanning.value!
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow)
          : null,
    );
  }
}
