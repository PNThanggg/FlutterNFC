import 'enums.dart';
import 'extensions.dart';
import 'ndef/ndef.dart' as ndef;

class NDEFRawRecord {
  final String identifier;
  final String payload;
  final String type;
  final ndef.TypeNameFormat typeNameFormat;

  NDEFRawRecord(this.identifier, this.payload, this.type, this.typeNameFormat);

  factory NDEFRawRecord.fromJson(Map<String, dynamic> json) => _$NDEFRawRecordFromJson(json);

  Map<String, dynamic> toJson() => _$NDEFRawRecordToJson(this);

  Map<String, dynamic> _$NDEFRawRecordToJson(NDEFRawRecord instance) => <String, dynamic>{
        'identifier': instance.identifier,
        'payload': instance.payload,
        'type': instance.type,
        'typeNameFormat': typeNameFormatEnumMap[instance.typeNameFormat],
      };
}

NDEFRawRecord _$NDEFRawRecordFromJson(Map<String, dynamic> json) {
  return NDEFRawRecord(
    json['identifier'] as String,
    json['payload'] as String,
    json['type'] as String,
    enumDecode(typeNameFormatEnumMap, json['typeNameFormat']),
  );
}