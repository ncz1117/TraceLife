// Web 平台下载实现 — 使用 dart:html
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' show AnchorElement, Blob, Url;

void downloadJson(String content, String fileName) {
  final blob = Blob([content], 'application/json');
  final url = Url.createObjectUrl(blob);
  final anchor = AnchorElement(href: url)
    ..target = 'blank'
    ..download = fileName;
  anchor.click();
  Url.revokeObjectUrl(url);
}
