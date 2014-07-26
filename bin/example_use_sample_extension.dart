import "package:native_extension_with_build_tools/sample_extension.dart";

void main() {
  print('====================');
  print('SysInfo example:');
  var isLittleEndian = SysInfo.isLittleEndian;
  var pageSize = SysInfo.pageSize;
  var sizeOfInt = SysInfo.sizeOfInt;
  var version = SysInfo.version;
  print('Dart VM (${sizeOfInt * 8} bit): $version');
  print('Page size: $pageSize KB');
  print('Endianness: ${isLittleEndian ? 'Little-endian' : 'Big-endian'}');
}
