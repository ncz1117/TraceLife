// Native 平台下载实现 — 使用 dart:io
import 'dart:io' show File, Directory;

String downloadJson(String content, String fileName) {
  final dir = Directory('/storage/emulated/0/Download');
  if (dir.existsSync()) {
    final file = File('${dir.path}/$fileName');
    file.writeAsStringSync(content);
    return file.path;
  }
  // 回退到临时目录
  final tmpFile = File('${Directory.systemTemp.path}/$fileName');
  tmpFile.writeAsStringSync(content);
  return tmpFile.path;
}
