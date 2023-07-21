import 'dart:convert';
import 'dart:typed_data';

import '../../type_data/src/typed_buffer.dart';

/// A sink that provides access to the concatenated bytes passed to it.
///
/// See also [ByteConversionSink.withCallback].
class ByteAccumulatorSink extends ByteConversionSinkBase {
  /// The bytes accumulated so far.
  ///
  /// The returned [Uint8List] is viewing a shared buffer, so it should not be
  /// changed and any bytes outside the view should not be accessed.
  Uint8List get bytes => Uint8List.view(_buffer.buffer, 0, _buffer.length);

  final _buffer = Uint8Buffer();

  /// Whether [close] has been called.
  bool get isClosed => _isClosed;
  var _isClosed = false;

  /// Removes all bytes from [bytes].
  ///
  /// This can be used to avoid double-processing data.
  void clear() {
    _buffer.clear();
  }

  @override
  void add(List<int> chunk) {
    if (_isClosed) {
      throw StateError("Can't add to a closed sink.");
    }

    _buffer.addAll(chunk);
  }

  @override
  void addSlice(List<int> chunk, int start, int end, bool isLast) {
    if (_isClosed) {
      throw StateError("Can't add to a closed sink.");
    }

    _buffer.addAll(chunk, start, end);
    if (isLast) _isClosed = true;
  }

  @override
  void close() {
    _isClosed = true;
  }
}
