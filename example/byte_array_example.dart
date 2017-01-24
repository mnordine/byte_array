import 'package:byte_array/byte_array.dart';

main() {
  final bytes = new ByteArray(6);
  bytes.writeFloat(33.6);
  bytes.writeUnsignedShort(5);

  print('length in bytes: ${bytes.length}');

  bytes.offset = 0;
  final float = bytes.readFloat();
  print(float);

  final short = bytes.readUnsignedShort();
  print(short);
}
