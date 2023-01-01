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
  bool isReading = false;

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
              if (!snapshot.hasData) {
                return const Center(
                  child: Text("Not Found Services..."),
                );
              }
              return SizedBox(
                height: 450,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    BluetoothService service = snapshot.data![index];
                    String uuid =
                        service.uuid.toString().substring(4, 8).toUpperCase();
                    return Card(
                      child: ExpansionTile(
                        leading: const Icon(Icons.electrical_services_outlined),
                        title: Text(uuidServiceMap[uuid] ?? "UnKnown Service"),
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: service.characteristics.length,
                            itemBuilder: (context, int indexChara) {
                              BluetoothCharacteristic characteristic = snapshot
                                  .data![index].characteristics[indexChara];
                              String uuidChara = characteristic.uuid
                                  .toString()
                                  .substring(4, 8)
                                  .toUpperCase();
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: Card(
                                  child: ExpansionTile(
                                    leading: const Icon(Icons.message_outlined),
                                    title: Text(
                                        uuidCharacteristicMap[uuidChara] ??
                                            "UnKnown Characteristics"),
                                    children: [
                                      Card(
                                        child: ListTile(
                                          title: Text(characteristic.lastValue
                                              .toString()),
                                          onTap: () async {
                                            await characteristic.read();
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
                    await widget.device.discoverServices();
                    setState(() {});
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
