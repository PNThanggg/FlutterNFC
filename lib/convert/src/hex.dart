import 'dart:convert';

import 'hex/decoder.dart';
import 'hex/encoder.dart';

export 'hex/decoder.dart' hide hexDecoder;
export 'hex/encoder.dart' hide hexEncoder;

const hex = HexCodec._();

class HexCodec extends Codec<List<int>, String> {
  @override
  HexEncoder get encoder => hexEncoder;

  @override
  HexDecoder get decoder => hexDecoder;

  const HexCodec._();
}
