// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceDetailPage extends StatelessWidget {
  const DeviceDetailPage({
    Key? key,
    required this.device,
  }) : super(key: key);
  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Detail"),
      ),
      body: ListView(
        children: [
          const CircleAvatar(
            radius: 60.0,
            child: Icon(Icons.bluetooth_outlined),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: [
                  const Text("デバイス情報"),
                  ListTile(
                    leading: const Text("デバイス名"),
                    title: Text(device.name),
                  ),
                  ListTile(
                    leading: const Text("ID"),
                    title: Text(device.id.toString()),
                  ),
                  ListTile(
                    leading: const Text("タイプ"),
                    title: Text(device.type.toString()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.amberAccent,
        height: 100,
        child: Row(
          children: [
            ElevatedButton(
              child: const Text("Connect"),
              onPressed: () async {
                await device.connect();
                Navigator.of(context).pop();
              },
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
