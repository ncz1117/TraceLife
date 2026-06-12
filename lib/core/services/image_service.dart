import 'dart:convert';
import 'dart:io' show File, Directory;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// 图片服务
/// - Native: 存到 app documents/images/ 下，DB 里存相对路径
/// - Web: 存为 base64 data URI
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// 单图大小上限（字节）
  static const int maxImageBytes = 2 * 1024 * 1024; // 2MB

  /// 图片数量上限
  static const int maxImagesPerDiary = 9;

  /// 选图（相册）
  /// 返回 List<String> — 路径或 data URI
  static Future<List<String>> pickFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null) return [];
    final result = await _processPickedFile(file);
    return [result];
  }

  /// 拍照
  static Future<List<String>> pickFromCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null) return [];
    final result = await _processPickedFile(file);
    return [result];
  }

  /// 处理选中的图片文件
  /// - Web: 转 base64
  /// - Native: 复制到 app docs，存相对路径
  static Future<String> _processPickedFile(XFile file) async {
    if (kIsWeb) {
      // Web：读字节转 base64 data URI
      final bytes = await file.readAsBytes();
      if (bytes.length > maxImageBytes) {
        throw Exception('图片太大，请选择 < 2MB 的图片');
      }
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    }
    // Native：复制到 app docs
    final bytes = await file.readAsBytes();
    if (bytes.length > maxImageBytes) {
      throw Exception('图片太大，请选择 < 2MB 的图片');
    }
    final docs = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${docs.path}/images');
    if (!imagesDir.existsSync()) {
      imagesDir.createSync(recursive: true);
    }
    final ext = file.name.split('.').last;
    final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final dest = File('${imagesDir.path}/$filename');
    await dest.writeAsBytes(bytes);
    // 存相对路径
    return 'images/$filename';
  }

  /// 把存储的路径/URI 解析为可在 Image.memory/Image.file 用的对象
  /// - Web data URI: 返回字节
  /// - Native 相对路径: 返回 File
  /// - Native data URI: 罕见，但兼容
  static dynamic resolveImage(String stored) {
    if (stored.startsWith('data:')) {
      // base64 → bytes
      final base64Str = stored.split(',').last;
      return base64Decode(base64Str);
    }
    if (kIsWeb) {
      // 未知格式
      return null;
    }
    // Native: 相对路径 → File
    // 走 lazy resolve（async），调用方应该用 resolveImageAsync
    return null;
  }

  /// Async 版的解析（拿到 File 路径）
  static Future<dynamic> resolveImageAsync(String stored) async {
    if (stored.startsWith('data:')) {
      final base64Str = stored.split(',').last;
      return base64Decode(base64Str);
    }
    if (kIsWeb) return null;
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/$stored');
  }

  /// 删除本地图片文件（Native only）
  static Future<void> deleteImage(String stored) async {
    if (kIsWeb || stored.startsWith('data:')) return;
    final docs = await getApplicationDocumentsDirectory();
    final file = File('${docs.path}/$stored');
    if (file.existsSync()) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }
}
