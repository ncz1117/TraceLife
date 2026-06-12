import 'package:flutter/material.dart';

/// 4 套主题预设
///
/// 设计意图：每套对应一种情绪/时刻，不是 4 个差不多的颜色：
/// - 默 (Default)：晨起 / 沉稳 / 通用（默认）
/// - 暮 (Sunset)：黄昏 / 温暖 / 回忆
/// - 雾 (Mist)：清晨 / 静谧 / 冥想
/// - 樱 (Cherry)：春 / 浪漫 / 喜悦
enum ThemePreset {
  moe(
    id: 'moe',
    name: '默',
    tagline: '沉静、克制',
    description: '默认主题。蓝紫色调，适合日常与晨间',
    seed: Color(0xFF4F46E5), // indigo-600
  ),
  mu(
    id: 'mu',
    name: '暮',
    tagline: '温暖、回忆',
    description: '黄昏橙红，适合怀旧与重要日子的记录',
    seed: Color(0xFFEA580C), // orange-600
  ),
  wu(
    id: 'wu',
    name: '雾',
    tagline: '静谧、冥想',
    description: '雾绿调，适合日记与自我对话',
    seed: Color(0xFF0F766E), // teal-700
  ),
  ying(
    id: 'ying',
    name: '樱',
    tagline: '浪漫、喜悦',
    description: '粉色调，适合纪念日与重要的人',
    seed: Color(0xFFDB2777), // pink-600
  );

  final String id;
  final String name;
  final String tagline;
  final String description;
  final Color seed;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.seed,
  });

  /// 从 id 还原（找不到回 moe）
  static ThemePreset fromId(String? id) {
    if (id == null) return ThemePreset.moe;
    return ThemePreset.values.firstWhere(
      (p) => p.id == id,
      orElse: () => ThemePreset.moe,
    );
  }
}
