import 'enums.dart';
import 'extensions.dart';

class NFCTag {
  /// Tag Type
  final NFCTagType type;

  /// The standard that the tag complies with (can be `unknown`)
  final String standard;

  /// Tag ID
  final String id;

  /// ATQA (Type A only, Android only)
  final String? atqa;

  /// SAK (Type A only, Android only)
  final String? sak;

  /// Historical bytes (ISO 14443-4A only)
  final String? historicalBytes;

  /// Higher layer response (ISO 14443-4B only, Android only)
  final String? hiLayerResponse;

  /// Protocol information (Type B only， Android only)
  final String? protocolInfo;

  /// Application data (Type B only)
  final String? applicationData;

  /// Manufacturer (ISO 18092 only)
  final String? manufacturer;

  /// System code (ISO 18092 only)
  final String? systemCode;

  /// DSF ID (ISO 15693 only, Android only)
  final String? dsfId;

  /// NDEF availability
  final bool? ndefAvailable;

  /// NDEF tag type (Android only)
  final String? ndefType;

  /// Maximum NDEF message size in bytes (only meaningful when ndef available)
  final int? ndefCapacity;

  /// NDEF writebility
  final bool? ndefWritable;

  /// Indicates whether this NDEF tag can be made read-only (only works on Android, always false on iOS)
  final bool? ndefCanMakeReadOnly;

  /// Custom probe data returned by WebUSB device (see [FlutterNfcKitWeb] for detail, only on Web)
  final String? webUSBCustomProbeData;

  NFCTag(
    this.type,
    this.id,
    this.standard,
    this.atqa,
    this.sak,
    this.historicalBytes,
    this.protocolInfo,
    this.applicationData,
    this.hiLayerResponse,
    this.manufacturer,
    this.systemCode,
    this.dsfId,
    this.ndefAvailable,
    this.ndefType,
    this.ndefCapacity,
    this.ndefWritable,
    this.ndefCanMakeReadOnly,
    this.webUSBCustomProbeData,
  );

  factory NFCTag.fromJson(Map<String, dynamic> json) => _$NFCTagFromJson(json);

  Map<String, dynamic> toJson() => _$NFCTagToJson(this);

  Map<String, dynamic> _$NFCTagToJson(NFCTag instance) => <String, dynamic>{
        'type': nfcTagTypeEnumMap[instance.type],
        'standard': instance.standard,
        'id': instance.id,
        'atqa': instance.atqa,
        'sak': instance.sak,
        'historicalBytes': instance.historicalBytes,
        'hiLayerResponse': instance.hiLayerResponse,
        'protocolInfo': instance.protocolInfo,
        'applicationData': instance.applicationData,
        'manufacturer': instance.manufacturer,
        'systemCode': instance.systemCode,
        'dsfId': instance.dsfId,
        'ndefAvailable': instance.ndefAvailable,
        'ndefType': instance.ndefType,
        'ndefCapacity': instance.ndefCapacity,
        'ndefWritable': instance.ndefWritable,
        'ndefCanMakeReadOnly': instance.ndefCanMakeReadOnly,
        'webUSBCustomProbeData': instance.webUSBCustomProbeData,
      };
}

NFCTag _$NFCTagFromJson(Map<String, dynamic> json) {
  return NFCTag(
    enumDecode(nfcTagTypeEnumMap, json['type']),
    json['id'] as String,
    json['standard'] as String,
    json['atqa'] as String?,
    json['sak'] as String?,
    json['historicalBytes'] as String?,
    json['protocolInfo'] as String?,
    json['applicationData'] as String?,
    json['hiLayerResponse'] as String?,
    json['manufacturer'] as String?,
    json['systemCode'] as String?,
    json['dsfId'] as String?,
    json['ndefAvailable'] as bool?,
    json['ndefType'] as String?,
    json['ndefCapacity'] as int?,
    json['ndefWritable'] as bool?,
    json['ndefCanMakeReadOnly'] as bool?,
    json['webUSBCustomProbeData'] as String?,
  );
}