import 'ndef/ndef.dart' as ndef;
import 'ndef_raw_record.dart';

extension NDEFRecordConvert on ndef.NDEFRecord {
  NDEFRawRecord toRaw() {
    return NDEFRawRecord(
      id?.toHexString() ?? '',
      payload?.toHexString() ?? '',
      type?.toHexString() ?? '',
      tnf,
    );
  }

  static ndef.NDEFRecord fromRaw(NDEFRawRecord raw) {
    return ndef.decodePartialNdefMessage(
      raw.typeNameFormat,
      raw.type.toBytes(),
      raw.payload.toBytes(),
      id: raw.identifier == "" ? null : raw.identifier.toBytes(),
    );
  }
}

K enumDecode<K, V>(
    Map<K, V> enumValues,
    Object? source, {
      K? unknownValue,
    }) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
          '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
        (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}