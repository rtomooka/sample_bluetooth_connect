// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
  TextEditingController textEditingController = TextEditingController();
  late BluetoothCharacteristic? bluetoothCharacteristic;

  @override
  void initState() {
    super.initState();
    Future(() async {
      await widget.device.discoverServices();
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Container(
                color: Colors.black,
                width: 400,
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder(
                      stream: widget.device.services,
                      builder: (context, snapshot) {
                        String message = "";
                        if (!snapshot.hasData) {
                          message = "No Services...";
                        } else {
                          snapshot.data!.toList().forEach((service) {
                            if (service.uuid.toString().contains("ffe0")) {
                              message += "uuid\n";
                              message += "${service.uuid}\n";
                              for (var characteristic
                                  in service.characteristics) {
                                message +=
                                    " characteristic : ${characteristic.uuid}\n";

                                if (characteristic.uuid
                                    .toString()
                                    .contains("ffe1")) {
                                  bluetoothCharacteristic = characteristic;

                                  message +=
                                      characteristic.properties.toString();
                                  message += "\n";
                                }
                              }
                              message += "\n";
                            }
                          });
                        }

                        return SingleChildScrollView(
                          child: Text(
                            message,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                ),
              ),
            ),
            TextField(
              controller: textEditingController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (String value) {
                textEditingController.text = value;
              },
              autofocus: true,
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  textEditingController.clear();
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Icon(Icons.delete_outline),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0)),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (bluetoothCharacteristic == null) return;
                  await bluetoothCharacteristic!.write(
                    utf8.encode(textEditingController.text),
                    withoutResponse: true,
                  );
                },
                child: const Icon(Icons.send_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
