import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logging/logging.dart';
import 'nfc/enums.dart';
import 'nfc/ndef/ndef.dart' as ndef;
import 'nfc/nfc.dart';
import 'nfc/nfc_tag.dart';
import 'record_setting/raw_record_setting.dart';
import 'record_setting/text_record_setting.dart';
import 'record_setting/uri_record_setting.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  String _platformVersion = '';
  NFCAvailability _availability = NFCAvailability.notSupported;
  NFCTag? _tag;
  String? _result, _writeResult;
  late TabController _tabController;
  List<ndef.NDEFRecord>? _records;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _platformVersion = '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';

    initPlatformState();

    _tabController = TabController(length: 2, vsync: this);
    _records = [];
  }

  Future<void> initPlatformState() async {
    NFCAvailability availability;
    try {
      availability = await Nfc.nfcAvailability;
    } on PlatformException {
      availability = NFCAvailability.notSupported;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
      _availability = availability;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NFC Flutter Kit Example App'),
          bottom: TabBar(
            tabs: const <Widget>[
              Tab(text: 'Read'),
              Tab(text: 'Write'),
            ],
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Scrollbar(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 20),
                      Text('Running on: $_platformVersion\nNFC: $_availability'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            NFCTag tag = await Nfc.poll();
                            setState(() {
                              _tag = tag;
                            });

                            await Nfc.setIosAlertMessage("Working on it...");

                            if (tag.standard == "ISO 14443-4 (Type B)") {
                              String result1 = await Nfc.transceiver("00B0950000");
                              String result2 =
                                  await Nfc.transceiver("00A4040009A00000000386980701");

                              setState(() {
                                _result = '1: $result1\n2: $result2\n';
                              });
                            } else if (tag.type == NFCTagType.iso18092) {
                              String result1 = await Nfc.transceiver("060080080100");

                              setState(() {
                                _result = '1: $result1\n';
                              });
                            } else if (tag.type == NFCTagType.mifareUltralight ||
                                tag.type == NFCTagType.mifareClassic ||
                                tag.type == NFCTagType.iso15693) {
                              var ndefRecords = await Nfc.readNDEFRecords();
                              var ndefString = '';
                              for (int i = 0; i < ndefRecords.length; i++) {
                                ndefString += '${i + 1}: ${ndefRecords[i]}\n';
                              }

                              setState(() {
                                _result = ndefString;
                              });
                            }
                          } catch (e) {
                            setState(() {
                              _result = 'error: $e';
                            });
                          }

                          // Pretend that we are working
                          await Nfc.finish(iosAlertMessage: "Finished!");
                        },
                        child: const Text('Start polling'),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _tag != null
                            ? Text(
                                'ID: ${_tag!.id}\nStandard: ${_tag!.standard}\nType: ${_tag!.type}\nATQA: ${_tag!.atqa}\nSAK: ${_tag!.sak}\nHistorical Bytes: ${_tag!.historicalBytes}\nProtocol Info: ${_tag!.protocolInfo}\nApplication Data: ${_tag!.applicationData}\nHigher Layer Response: ${_tag!.hiLayerResponse}\nManufacturer: ${_tag!.manufacturer}\nSystem Code: ${_tag!.systemCode}\nDSF ID: ${_tag!.dsfId}\nNDEF Available: ${_tag!.ndefAvailable}\nNDEF Type: ${_tag!.ndefType}\nNDEF Writable: ${_tag!.ndefWritable}\nNDEF Can Make Read Only: ${_tag!.ndefCanMakeReadOnly}\nNDEF Capacity: ${_tag!.ndefCapacity}\n\n Transceiver Result:\n$_result',
                              )
                            : const Text('No tag polled yet.'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          if (_records!.isNotEmpty) {
                            try {
                              NFCTag tag = await Nfc.poll();

                              setState(() {
                                _tag = tag;
                              });

                              if (tag.type == NFCTagType.mifareUltralight ||
                                  tag.type == NFCTagType.mifareClassic ||
                                  tag.type == NFCTagType.iso15693) {
                                await Nfc.writeNDEFRecords(_records!);
                                setState(
                                  () {
                                    _writeResult = 'OK';
                                  },
                                );
                              } else {
                                setState(
                                  () {
                                    _writeResult = 'error: NDEF not supported: ${tag.type}';
                                  },
                                );
                              }
                            } catch (e, stacktrace) {
                              setState(
                                () {
                                  _writeResult = 'error: $e';
                                },
                              );
                              debugPrint(stacktrace.toString());
                            } finally {
                              await Nfc.finish();
                            }
                          } else {
                            setState(
                              () {
                                _writeResult = 'error: No record';
                              },
                            );
                          }
                        },
                        child: const Text(
                          "Start writing",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SimpleDialog(
                                title: const Text("Record Type"),
                                children: <Widget>[
                                  SimpleDialogOption(
                                    child: const Text("Text Record"),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return TextRecordSetting();
                                          },
                                        ),
                                      );

                                      if (result != null) {
                                        if (result is ndef.TextRecord) {
                                          setState(
                                            () {
                                              _records!.add(result);
                                            },
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  SimpleDialogOption(
                                    child: const Text(
                                      "Uri Record",
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return UriRecordSetting();
                                          },
                                        ),
                                      );

                                      if (result != null) {
                                        if (result is ndef.UriRecord) {
                                          setState(() {
                                            _records!.add(result);
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  SimpleDialogOption(
                                    child: const Text("Raw Record"),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return NDEFRecordSetting();
                                          },
                                        ),
                                      );

                                      if (result != null) {
                                        if (result is ndef.NDEFRecord) {
                                          setState(
                                            () {
                                              _records!.add(result);
                                            },
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          "Add record",
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Result: $_writeResult'),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      shrinkWrap: true,
                      children: List<Widget>.generate(
                        _records!.length,
                        (index) => GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              'id:${_records![index].idString}\ntnf:${_records![index].tnf}\ntype:${_records![index].type?.toHexString()}\npayload:${_records![index].payload?.toHexString()}\n',
                            ),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return NDEFRecordSetting(record: _records![index]);
                                },
                              ),
                            );

                            if (result != null) {
                              if (result is ndef.NDEFRecord) {
                                setState(() {
                                  _records![index] = result;
                                });
                              } else if (result is String && result == "Delete") {
                                _records!.removeAt(index);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
