import 'dart:convert';

import 'percent/decoder.dart';
import 'percent/encoder.dart';

export 'percent/decoder.dart' hide percentDecoder;
export 'percent/encoder.dart' hide percentEncoder;

/// The canonical instance of [PercentCodec].
const percent = PercentCodec._();

/// A codec that converts byte arrays to and from percent-encoded (also known as
/// URL-encoded) strings according to
/// [RFC 3986](https://tools.ietf.org/html/rfc3986#section-2.1).
///
/// [encoder] encodes all bytes other than ASCII letters, decimal digits, or one
/// of `-._~`. This matches the behavior of [Uri.encodeQueryComponent] except
/// that it doesn't encode `0x20` bytes to the `+` character.
///
/// To be maximally flexible, [decoder] will decode any percent-encoded byte and
/// will allow any non-percent-encoded byte other than `%`. By default, it
/// interprets `+` as `0x2B` rather than `0x20` as emitted by
/// [Uri.encodeQueryComponent].
class PercentCodec extends Codec<List<int>, String> {
  @override
  PercentEncoder get encoder => percentEncoder;
  @override
  PercentDecoder get decoder => percentDecoder;

  const PercentCodec._();
}
