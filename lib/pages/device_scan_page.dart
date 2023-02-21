import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sample_bluetooth_connect/notifier/bluetooth_state_notifer.dart';
import 'package:sample_bluetooth_connect/pages/device_detail_page.dart';

class DeviceScanPage extends ConsumerStatefulWidget {
  const DeviceScanPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DeviceScanPage> createState() => _DeviceScanPageState();
}

class _DeviceScanPageState extends ConsumerState<DeviceScanPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      return const Center(child: Text("Ready to Scan..."));
    } else {
      return ListView.builder(
          itemCount: bluetoothScanResult.value!.length,
          itemBuilder: (context, index) {
            final device = bluetoothScanResult.value![index].device;
            final advertisementData =
                bluetoothScanResult.value![index].advertisementData;
            return Card(
              child: ListTile(
                title:
                    device.name.isEmpty ? const Text("N/A") : Text(device.name),
                subtitle: Text(device.id.toString()),
                trailing: StreamBuilder(
                  stream: device.state,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.data ==
                        BluetoothDeviceState.connected) {
                      return ElevatedButton(
                        onPressed: () {},
                        child: const Text("DISCONNECT"),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () async {
                          try {
                            await device.connect(
                                timeout: const Duration(seconds: 5));
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (BuildContext buildContext) {
                                return AlertDialog(
                                  title: Text(e.toString()),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      child: const Text("RETURN"),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }
                          if (!mounted) return;
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  DeviceDetailPage(device: device)));
                        },
                        child: const Text("CONNECT"),
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
          await FlutterBluePlus.instance.startScan(
            timeout: const Duration(seconds: 5),
            macAddresses: ["38:81:D7:1B:21:9C"],
          );
        }
      },
      backgroundColor: bluetoothScanning.hasValue
          ? bluetoothScanning.value!
              ? Colors.redAccent
              : Colors.blue
          : Colors.grey,
      child: bluetoothScanning.hasValue
          ? bluetoothScanning.value!
              ? const Text("STOP")
              : const Text("SCAN")
          : null,
    );
  }
}
