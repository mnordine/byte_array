import 'package:byte_array/byte_array.dart';
import 'package:test/test.dart';
import 'dart:typed_data' show Endianness;

main() {
  group('ByteArray', () {

    test('byte read/write range', () {
      var bytes = new ByteArray(4)
        ..writeByte(-128)
        ..writeByte(-129)
        ..writeByte(127)
        ..writeByte(128)
        ..offset = 0;

      var values = new List.generate(bytes.length, (_) => bytes.readByte());
      expect(values, orderedEquals([-128, 127, 127, -128]));
    });

    test('unsigned byte read/write range', () {
      var bytes = new ByteArray(2)
        ..writeUnsignedByte(255)
        ..writeUnsignedByte(256)
        ..offset = 0;

      var values = new List.generate(bytes.length, (_) => bytes.readUnsignedByte());
      expect(values, orderedEquals([255, 0]));
    });

    test('boolean read/write', () {
      var bytes = new ByteArray(2)
        ..writeBoolean(true)
        ..writeBoolean(false)
        ..offset = 0;

      expect(bytes.readBoolean(), isTrue);
      expect(bytes.readBoolean(), isFalse);
    });

    test('short read/write range', () {
      var bytes = new ByteArray(16)
        ..writeShort(-32768)
        ..writeShort(-32769)
        ..writeShort(32767)
        ..writeShort(32768)
        ..offset = 0;

      var values = new List.generate(4, (_) => bytes.readShort());
      expect(values, orderedEquals([-32768, 32767, 32767, -32768]));
    });

    test('unsigned short read/write range', () {
      var bytes = new ByteArray(4)
        ..writeUnsignedShort(65535)
        ..writeUnsignedShort(65536)
        ..offset = 0;

      var values = new List.generate(2, (_) => bytes.readUnsignedShort());
      expect(values, orderedEquals([65535, 0]));
    });

    test('int read/write range', () {
      var bytes = new ByteArray(16)
        ..writeInt(-2147483648)
        ..writeInt(-2147483649)
        ..writeInt(2147483647)
        ..writeInt(2147483648)
        ..offset = 0;

      var values = new List.generate(4, (_) => bytes.readInt());

      expect(values, orderedEquals([-2147483648, 2147483647, 2147483647, -2147483648]));
    });

    test('unsigned int read/write range', () {
      var bytes = new ByteArray(8)
        ..writeUnsignedInt(4294967295)
        ..writeUnsignedInt(4294967296)
        ..offset = 0;

      var values = new List.generate(2, (_) => bytes.readUnsignedInt());

      expect(values, orderedEquals([4294967295, 0]));
    });

    test('long read/write range', () {
      var bytes = new ByteArray(32)
        ..writeLong(-9223372036854775808)
        ..writeLong(-9223372036854775809)
        ..writeLong(9223372036854775807)
        ..writeLong(9223372036854775808)
        ..offset = 0;

      var values = new List.generate(4, (_) => bytes.readLong());

      expect(values, orderedEquals([-9223372036854775808, 9223372036854775807, 9223372036854775807, -9223372036854775808]));
    });

    test('unsigned long read/write range', () {
      var bytes = new ByteArray(16)
        ..writeUnsignedLong(9223372036854775808 * 2 - 1)
        ..writeUnsignedLong(9223372036854775808 * 2)
        ..offset = 0;

      var values = new List.generate(2, (_) => bytes.readUnsignedLong());

      expect(values, orderedEquals([9223372036854775808 * 2 - 1, 0]));
    });

    test('float read/write range', () {

      var floats = [-5.5, 23423.234, 89089.884, -343.233];

      var bytes = new ByteArray(floats.length * 4);

      floats.forEach((x) => bytes.writeFloat(x));

      bytes.offset = 0;
      var values = new List.generate(floats.length, (_) => bytes.readFloat());

      for (var i = 0; i < floats.length; i++)
      {
        var x = floats[i];
        var y = values[i];

        expect(x, closeTo(y, .01));
      }
    });

    test('double read/write range', () {

      var dubs = [-5.5, 234623.234, 89089.884, -343.233];

      var bytes = new ByteArray(dubs.length * 8);

      dubs.forEach((x) => bytes.writeDouble(x));

      bytes.offset = 0;
      var values = new List.generate(dubs.length, (_) => bytes.readDouble());

      for (var i = 0; i < dubs.length; i++)
      {
        var x = dubs[i];
        var y = values[i];

        expect(x, closeTo(y, .01));
      }
    });

    test('bytes read/write', () {

      // Test copying entire ByteArray
      var from = new ByteArray(38)
        ..writeFloat(5.5)
        ..writeUnsignedByte(2)
        ..writeLong(-5)
        ..writeDouble(5.5)
        ..writeByte(-5)
        ..writeUnsignedLong(5)
        ..writeUnsignedInt(10)
        ..writeInt(-20)
        ..offset = 0;

      var to = new ByteArray(from.length)
        ..writeBytes(from)
        ..offset = 0;

      expect(to.readFloat(), closeTo(from.readFloat(), .01));
      expect(to.readUnsignedByte(), equals(from.readUnsignedByte()));
      expect(to.readLong(), equals(from.readLong()));
      expect(to.readDouble(), closeTo(from.readDouble(), .01));
      expect(to.readByte(), equals(from.readByte()));
      expect(to.readUnsignedLong(), equals(from.readUnsignedLong()));
      expect(to.readUnsignedInt(), equals(from.readUnsignedInt()));
      expect(to.readInt(), equals(from.readInt()));

      // Test copying slice of ByteArray
      var len = 25;
      to = new ByteArray(len)
        ..writeBytes(from, 5, len)
        ..offset = 0;

      from.offset = 5;

      expect(to.readLong(), equals(from.readLong()));
      expect(to.readDouble(), equals(from.readDouble()));
      expect(to.readByte(), equals(from.readByte()));
      expect(to.readUnsignedLong(), equals(from.readUnsignedLong()));
    });

    test('mixed read/write', () {
      var bytes = new ByteArray(38)
        ..writeFloat(5.5)
        ..writeUnsignedByte(2)
        ..writeLong(-5)
        ..writeDouble(5.5)
        ..writeByte(-5)
        ..writeUnsignedLong(5)
        ..writeUnsignedInt(10)
        ..writeInt(-20)
        ..offset = 0;

      expect(bytes.readFloat(), closeTo(5.5, .01));
      expect(bytes.readUnsignedByte(), equals(2));
      expect(bytes.readLong(), equals(-5));
      expect(bytes.readDouble(), closeTo(5.5, .01));
      expect(bytes.readByte(), equals(-5));
      expect(bytes.readUnsignedLong(), equals(5));
      expect(bytes.readUnsignedInt(), equals(10));
      expect(bytes.readInt(), equals(-20));
    });

    test('length', () {
      var bytes = new ByteArray(38)
        ..writeFloat(5.5)
        ..writeUnsignedByte(2)
        ..writeLong(-5)
        ..writeDouble(5.5)
        ..writeByte(-5)
        ..writeUnsignedLong(5)
        ..writeUnsignedInt(10)
        ..writeInt(-20)
        ..offset = 0;

      expect(bytes.length, equals(38));
    });

    test('offset', () {
      var bytes = new ByteArray(38)
        ..writeFloat(5.5)
        ..writeUnsignedByte(2)
        ..writeLong(-5)
        ..writeDouble(5.5)
        ..writeByte(-5)
        ..writeUnsignedLong(5)
        ..writeUnsignedInt(10)
        ..writeInt(-20)
        ..offset = 0;

      bytes.offset = 34;
      expect(bytes.readInt(), equals(-20));

      bytes.offset = 13;
      expect(bytes.readDouble(), closeTo(5.5, .001));
    });

    test('invalid offset throws', () {
      var bytes = new ByteArray(4);
      expect(() => bytes.offset = 8, throwsRangeError);
    });

    test('writing too far throws range error', () {
      var bytes = new ByteArray(1);
      expect(() => bytes.writeInt(50), throwsRangeError);
    });

    test('change endianness', () {
      var bytes = new ByteArray(2);
      bytes.endianness = Endianness.LITTLE_ENDIAN;

      bytes
        ..writeShort(50)
        ..endianness = Endianness.BIG_ENDIAN
        ..offset = 0;

      expect(bytes.readShort(), equals(12800));
    });

    test('bytes available', () {
      var bytes = new ByteArray(38)
        ..writeFloat(5.5)
        ..writeUnsignedByte(2)
        ..writeLong(-5)
        ..writeDouble(5.5)
        ..writeByte(-5)
        ..writeUnsignedLong(5)
        ..writeUnsignedInt(10)
        ..writeInt(-20)
        ..offset = 0;

      expect(bytes.bytesAvailable, equals(bytes.length));

      bytes.offset = 34;
      expect(bytes.bytesAvailable, equals(4));

    });

    test('index operator: []', () {
      var bytes = new ByteArray(4)
        ..[0] = 1
        ..[1] = 2
        ..[2] = 3
        ..[3] = 4;

      expect(bytes[0], equals(1));
      expect(bytes[1], equals(2));
      expect(bytes[2], equals(3));
      expect(bytes[3], equals(4));
    });

    test('+ operator', () {
      var b1 = new ByteArray(2)
        ..[0] = 1
        ..[1] = 2;

      var b2 = new ByteArray(2)
        ..[0] = 3
        ..[1] = 4;

      var bytes = b1 + b2;

      expect(bytes[0], equals(1));
      expect(bytes[1], equals(2));
      expect(bytes[2], equals(3));
      expect(bytes[3], equals(4));

      var b3 = new ByteArray(2)
        ..[0] = 5
        ..[1] = 6;

      bytes += b3;

      expect(bytes[4], equals(5));
      expect(bytes[5], equals(6));
    });

    test('equality', () {
      var bytes = new ByteArray(38)
        ..writeFloat(5.5)
        ..writeUnsignedByte(2)
        ..writeLong(-5)
        ..writeDouble(5.5)
        ..writeByte(-5)
        ..writeUnsignedLong(5)
        ..writeUnsignedInt(10)
        ..writeInt(-20)
        ..offset = 0;

      var bytes2 = new ByteArray(38)
        ..writeFloat(5.5)
        ..writeUnsignedByte(2)
        ..writeLong(-5)
        ..writeDouble(5.5)
        ..writeByte(-5)
        ..writeUnsignedLong(5)
        ..writeUnsignedInt(10)
        ..writeInt(-20)
        ..offset = 0;

      expect(bytes, equals(bytes2));
    });

    test('byte stream', () {
      final ints = [2,2,5,5,5,3,3];
      final bytes = new ByteArray(ints.length);
      for (var i in ints) bytes.writeUnsignedByte(i);

      bytes.offset = 0;
      for (var i in bytes.byteStream().skip(2).take(3)) {
        expect(i, 5);
      }
    });

  });
}
