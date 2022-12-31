// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sample_bluetooth_connect/util/uuid_map.dart';

class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({
    Key? key,
    required this.device,
  }) : super(key: key);
  final BluetoothDevice device;

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.device.disconnect();
    super.dispose();
  }

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
                    leading: StreamBuilder(
                      stream: widget.device.state,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Icon(Icons.error_outline);
                        } else if (snapshot.data ==
                            BluetoothDeviceState.connecting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.data ==
                            BluetoothDeviceState.connected) {
                          return const Icon(Icons.bluetooth_connected_outlined);
                        } else {
                          return const Icon(Icons.bluetooth_disabled_outlined);
                        }
                      },
                    ),
                    // leading: const Icon(Icons.bluetooth_connected),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("デバイス名 : ${widget.device.name}"),
                        Text("id : ${widget.device.id.toString()}"),
                      ],
                    ),
                    subtitle: Text("type : ${widget.device.type.toString()}"),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder(
            stream: widget.device.services,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  String uuid = snapshot.data![index].uuid
                      .toString()
                      .substring(4, 8)
                      .toUpperCase();
                  return Card(
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.electrical_services_outlined),
                      title: Text(uuidMap[uuid] ?? "UnKnown Service"),
                      onTap: () {
                        snapshot.data![index].characteristics
                            .forEach((element) async {
                          final result = await element.read();
                          Future.delayed(Duration(microseconds: 200));
                          print(result);
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      bottomSheet: StreamBuilder(
        stream: widget.device.state,
        builder: (context, snapshot) {
          if (snapshot.data == BluetoothDeviceState.connected) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await widget.device.disconnect();
                    setState(() {
                      print("disconnected!!");
                    });
                  },
                  child: const Text("DISCONNECT"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final services = await widget.device.discoverServices();
                    setState(() {
                      print(services);
                    });
                  },
                  child: const Text("FIND SERVICES"),
                ),
              ],
            );
          } else if (snapshot.data == BluetoothDeviceState.disconnected) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await widget.device.connect();
                    setState(() {
                      print("connected!!");
                    });
                  },
                  child: const Text("CONNECT"),
                ),
              ],
            );
          } else {
            return const Text("Loading...");
          }
        },
      ),
    );
  }
}

// ToDo 接続したデバイスをProviderに登録する
// ToDo ConsumerWidgetへ変更する
