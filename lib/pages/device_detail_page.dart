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
  TextEditingController writeTextEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<String> commandList = [];
  late BluetoothCharacteristic? bluetoothCharacteristic;

  @override
  void initState() {
    super.initState();
    Future(() async {
      await widget.device.discoverServices();
      print("discoverServices");
      await Future.delayed(const Duration(milliseconds: 500));
      print("Delay");
      await initBluetoothCharacteristic();
      print("initBluetoothCharacteristic");
    });
  }

  Future<void> initBluetoothCharacteristic() async {
    widget.device.services.listen((event) {
      for (var service in event) {
        if (service.uuid.toString().contains("ffe0")) {
          print(service.uuid.toString());
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().contains("ffe1")) {
              bluetoothCharacteristic = characteristic;
              print(characteristic.uuid.toString());
              break;
            }
          }
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant DeviceDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    commandList.clear();
    scrollController.dispose();
    writeTextEditingController.dispose();
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
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Text(
                      commandList.join('\n'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            TextField(
              controller: writeTextEditingController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (String value) {
                writeTextEditingController.text = value;
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
                  writeTextEditingController.clear();
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
                  try {
                    await bluetoothCharacteristic!.write(
                      utf8.encode(writeTextEditingController.text),
                      withoutResponse: true,
                    );
                    commandList.add(writeTextEditingController.text);
                    setState(() {
                      // 古いログを破棄する
                      while (commandList.length > 50) {
                        commandList.removeAt(0);
                      }
                    });
                    //オーバースクロールして末尾まで移動する
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent * 2.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.bounceInOut,
                    );
                  } catch (event) {
                    print("error!! failed to Read()...");
                  }
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
