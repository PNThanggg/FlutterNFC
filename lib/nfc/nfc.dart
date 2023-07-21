import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'enums.dart';
import 'extensions.dart';
import 'ndef/ndef.dart' as ndef;
import 'ndef_raw_record.dart';
import 'nfc_tag.dart';

class Nfc {
  /// Default timeout for [transceiver] (in milliseconds)
  static const int transceiverTimeout = 5 * 1000;

  /// Default timeout for [poll] (in milliseconds)
  static const int pollTimeout = 20 * 1000;

  static const MethodChannel _channel = MethodChannel('nfc');

  static Future<NFCAvailability> get nfcAvailability async {
    final String availability = await _channel.invokeMethod('getNFCAvailability');

    return NFCAvailability.values
        .firstWhere((it) => it.toString() == "NFCAvailability.$availability");
  }

  static Future<NFCTag> poll({
    Duration? timeout,
    bool androidPlatformSound = true,
    bool androidCheckNDEF = true,
    String iosAlertMessage = "Hold your iPhone near the card",
    String iosMultipleTagMessage =
        "More than one tags are detected, please leave only one tag and try again.",
    bool readIso14443A = true,
    bool readIso14443B = true,
    bool readIso18092 = false,
    bool readIso15693 = true,
  }) async {
    // use a bitmask for compact representation
    int technologies = 0x0;
    // hardcoded bits, corresponding to flags in android.nfc.NfcAdapter
    if (readIso14443A) technologies |= 0x1;
    if (readIso14443B) technologies |= 0x2;
    if (readIso18092) technologies |= 0x4;
    if (readIso15693) technologies |= 0x8;
    // iOS can safely ignore these option bits
    if (!androidCheckNDEF) technologies |= 0x80;
    if (!androidPlatformSound) technologies |= 0x100;

    final String data = await _channel.invokeMethod(
      'poll',
      {
        'timeout': timeout?.inMilliseconds ?? pollTimeout,
        'iosAlertMessage': iosAlertMessage,
        'iosMultipleTagMessage': iosMultipleTagMessage,
        'technologies': technologies,
      },
    );

    return NFCTag.fromJson(jsonDecode(data));
  }

  static Future<void> setIosAlertMessage(String message) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod('setIosAlertMessage', message);
    }
  }

  static Future<T> transceiver<T>(T capdu, {Duration? timeout}) async {
    assert(capdu is String || capdu is Uint8List);

    return await _channel.invokeMethod(
      'transceiver',
      {
        'data': capdu,
        'timeout': timeout?.inMilliseconds ?? transceiverTimeout,
      },
    );
  }

  static Future<List<ndef.NDEFRecord>> readNDEFRecords({bool? cached}) async {
    return (await readNDEFRawRecords(cached: cached))
        .map((r) => NDEFRecordConvert.fromRaw(r))
        .toList();
  }

  static Future<List<NDEFRawRecord>> readNDEFRawRecords({bool? cached}) async {
    final String data = await _channel.invokeMethod(
      'readNDEF',
      {
        'cached': cached ?? false,
      },
    );

    return (jsonDecode(data) as List<dynamic>)
        .map((object) => NDEFRawRecord.fromJson(object))
        .toList();
  }

  static Future<void> writeNDEFRawRecords(List<NDEFRawRecord> message) async {
    var data = jsonEncode(message);
    return await _channel.invokeMethod(
      'writeNDEF',
      {
        'data': data,
      },
    );
  }

  static Future<void> writeNDEFRecords(List<ndef.NDEFRecord> message) async {
    return await writeNDEFRawRecords(message.map((r) => r.toRaw()).toList());
  }

  static Future<void> finish({
    String? iosAlertMessage,
    String? iosErrorMessage,
  }) async {
    return await _channel.invokeMethod(
      'finish',
      {
        'iosErrorMessage': iosErrorMessage,
        'iosAlertMessage': iosAlertMessage,
      },
    );
  }
}
