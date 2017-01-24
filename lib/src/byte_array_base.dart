import 'dart:typed_data';
import 'package:typed_data/typed_data.dart';
import 'package:typed_data/typed_buffers.dart';

/// Read and write to an array of bytes
class ByteArray
{
  ByteData _byteData;
  Endianness endianness;
  int _offset = 0;

  ByteArray([int length = 0, this.endianness = Endianness.LITTLE_ENDIAN])
  {
    final buff = new Uint8Buffer(length);
    _byteData = new ByteData.view(buff.buffer);
  }

  ByteArray.fromByteData(this._byteData, [this.endianness = Endianness.LITTLE_ENDIAN]);

  factory ByteArray.fromBuffer(ByteBuffer buffer,
      [int offset = 0, int length = null, Endianness endianness = Endianness.LITTLE_ENDIAN])
  {
    length ??= buffer.lengthInBytes - offset;

    final view = new ByteData.view(buffer, offset, length);
    return new ByteArray.fromByteData(view, endianness);
  }

  int readByte() => _getNum(_byteData.getInt8, 1);
  int readUnsignedByte() => _getNum(_byteData.getUint8, 1);

  /// Returns true if not equal to zero
  bool readBoolean() => readByte() != 0;

  int readShort() => _getNum(_byteData.getInt16, 2);
  int readUnsignedShort() => _getNum(_byteData.getUint16, 2);

  int readInt() => _getNum(_byteData.getInt32, 4);
  int readUnsignedInt() => _getNum(_byteData.getUint32, 4);

  int readLong() => _getNum(_byteData.getInt64, 8);
  int readUnsignedLong() => _getNum(_byteData.getUint64, 8);

  double readFloat() => _getNum(_byteData.getFloat32, 4);
  double readDouble() => _getNum(_byteData.getFloat64, 8);

  writeByte(int value) => _setNum(_byteData.setInt8, value, 1);
  writeUnsignedByte(int value) => _setNum(_byteData.setUint8, value, 1);

  /// Writes [int], 1 if true, zero if false
  writeBoolean(bool value) => writeByte(value ? 1 : 0);

  writeShort(int value) => _setNum(_byteData.setInt16, value, 2);
  writeUnsignedShort(int value) => _setNum(_byteData.setUint16, value, 2);

  writeInt(int value) => _setNum(_byteData.setInt32, value, 4);
  writeUnsignedInt(int value) => _setNum(_byteData.setUint32, value, 4);

  writeLong(int value) => _setNum(_byteData.setInt64, value, 8);
  writeUnsignedLong(int value) => _setNum(_byteData.setUint64, value, 8);

  writeFloat(double value) => _setNum(_byteData.setFloat32, value, 4);
  writeDouble(double value) => _setNum(_byteData.setFloat64, value, 8);

  /// Get byte at given index
  int operator [] (int i) => _byteData.getInt8(i);

  /// Set byte at given index
  operator []= (int i, int value) => _byteData.setInt8(i, value);

  /// Appends [other] to [this]
  ByteArray operator + (ByteArray other)
  {
    final bytes = new ByteArray(length + other.length);
    bytes.writeBytes(this);
    bytes.writeBytes(other);

    return bytes;
  }

  Iterable<int> byteStream() sync*
  {
    while (offset < length) yield this[offset++];
  }

  /// Returns true if every byte in both [ByteArray]s are equal
  /// Note: offsets will not be affected
  bool operator == (Object otherObject)
  {
    if (otherObject is! ByteArray) return false;

    ByteArray other = otherObject;

    if (length != other.length) return false;

    for (var i = 0; i < length; i++) if (this[i] != other[i]) return false;

    return true;
  }

  /// Copies bytes from [bytes] to [this]
  writeBytes(ByteArray bytes, [int offset = 0, int byteCount = 0])
  {
    if (byteCount == 0) byteCount = bytes.length;

    // Copy old offset so we can reset it after copy
    final oldOffset = bytes.offset;
    bytes.offset = offset;

    for (var i = 0; i < byteCount; i++)
      writeByte(bytes.readByte());

    bytes.offset = oldOffset;
  }

  _setNum(Function fun, num value, int size)
  {
    if (_offset + size > length)
      throw new RangeError('attempted to write to offset ${_offset + size}, length is $length');

    if (fun == _byteData.setInt8 || fun == _byteData.setUint8)
      fun(_offset, value);
    else
      fun(_offset, value, endianness);

    _offset += size;
  }

  num _getNum(Function fun, int size)
  {
    if (_offset + size > length)
      throw new RangeError('attempted to read from offset ${_offset + size}, length is $length');

    num data = 0;
    if (fun == _byteData.getInt8 || fun == _byteData.getUint8)
      data = fun(_offset);
    else
      data = fun(_offset, endianness);

    _offset += size;
    return data;
  }

  int get length => _byteData.lengthInBytes;

  ByteBuffer get buffer => _byteData.buffer;

  int get bytesAvailable => length - _offset;

  int get offset => _offset;
  set offset(int value)
  {
    if (value < 0 || value > length)
      throw new RangeError('attempting to set offset to $value, length is $length');

    _offset = value;
  }
}
