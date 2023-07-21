import 'ndef/record.dart';

/// Availability of the NFC reader.
enum NFCAvailability {
  notSupported,
  disabled,
  available,
}

/// Type of NFC tag.
enum NFCTagType {
  iso7816,
  iso15693,
  iso18092,
  mifareClassic,
  mifareUltralight,
  mifareDesfire,
  mifarePlus,
  unknown,
}

const nfcTagTypeEnumMap = {
  NFCTagType.iso7816: 'iso7816',
  NFCTagType.iso15693: 'iso15693',
  NFCTagType.iso18092: 'iso18092',
  NFCTagType.mifareClassic: 'mifare_classic',
  NFCTagType.mifareUltralight: 'mifare_ultralight',
  NFCTagType.mifareDesfire: 'mifare_desfire',
  NFCTagType.mifarePlus: 'mifare_plus',
  NFCTagType.unknown: 'unknown',
};

const typeNameFormatEnumMap = {
  TypeNameFormat.empty: 'empty',
  TypeNameFormat.nfcWellKnown: 'nfcWellKnown',
  TypeNameFormat.media: 'media',
  TypeNameFormat.absoluteURI: 'absoluteURI',
  TypeNameFormat.nfcExternal: 'nfcExternal',
  TypeNameFormat.unknown: 'unknown',
  TypeNameFormat.unchanged: 'unchanged',
};
