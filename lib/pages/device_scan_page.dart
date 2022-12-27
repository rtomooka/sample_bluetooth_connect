import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sample_bluetooth_connect/notifier/bluetooth_state_notifer.dart';

class DeviceScanPage extends ConsumerWidget {
  const DeviceScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bluetoothState = ref.watch(bluetoothStateProvider);
    final bluetoothScanning = ref.watch(bluetoothScanningProvider);
    final bluetoothDevices = ref.watch(bluetoothConnectedDeviceProvider);
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
      body: bluetoothDevices.value!.isNotEmpty
          ? ListView.builder(
              itemCount: bluetoothDevices.value!.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 8.0,
                  child: ListTile(
                    leading: bluetoothDevices.value!.elementAt(index).type ==
                            BluetoothDeviceType.unknown
                        ? const Icon(Icons.question_mark_outlined)
                        : const Icon(Icons.smartphone_outlined),
                    title: Text(bluetoothDevices.value!.elementAt(index).name),
                    subtitle: Text(
                        bluetoothDevices.value!.elementAt(index).id.toString()),
                    trailing: StreamBuilder<BluetoothDeviceState>(
                      stream: bluetoothDevices.value!.elementAt(index).state,
                      initialData: BluetoothDeviceState.disconnected,
                      builder: (context, snapshot) {
                        if (snapshot.data == BluetoothDeviceState.connected) {
                          return ElevatedButton(
                            onPressed: () {
                              // ToDo 詳細ページへの遷移
                              // print(snapshot.data.toString());
                            },
                            child: const Icon(Icons.open_in_new_outlined),
                          );
                        }
                        return Text(snapshot.data.toString());
                      },
                    ),
                  ),
                );
              })
          : const Center(
              child: Text("No Devices..."),
            ),
      floatingActionButton: FloatingActionButton(
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
        backgroundColor: bluetoothScanning.value!
            ? Colors.redAccent
            : Theme.of(context).primaryColor,
        child: bluetoothScanning.value!
            ? const Icon(Icons.pause)
            : const Icon(Icons.play_arrow),
      ),
    );
  }
}
