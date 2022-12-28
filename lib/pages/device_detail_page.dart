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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.bluetooth_connected),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("デバイス名 : ${device.name}"),
                        Text("id : ${device.id.toString()}"),
                      ],
                    ),
                    subtitle: Text("type : ${device.type.toString()}"),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Card(
              child: ListTile(
                leading: StreamBuilder(
                  stream: device.isDiscoveringServices,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Icon(Icons.error);
                    } else if (snapshot.data!) {
                      return const CircularProgressIndicator();
                    } else {
                      return const Icon(Icons.bluetooth_connected_outlined);
                    }
                  },
                ),
                title: StreamBuilder(
                  stream: device.services,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("Loading...");
                    } else if (snapshot.data!.isEmpty) {
                      return const Text("Not found Services...");
                    } else {
                      return Text(snapshot.data.toString());
                    }
                  },
                ),
                trailing: ElevatedButton(
                  child: const Icon(Icons.play_arrow),
                  onPressed: () {
                    device.discoverServices();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ToDo 接続したデバイスをProviderに登録する
// ToDo ConsumerWidgetへ変更する
