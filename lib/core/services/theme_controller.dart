import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_presets.dart';

/// 用户主题设置
class ThemeSettings {
  final ThemePreset preset;
  final ThemeMode mode; // system / light / dark

  const ThemeSettings({required this.preset, required this.mode});

  ThemeSettings copyWith({ThemePreset? preset, ThemeMode? mode}) =>
      ThemeSettings(
        preset: preset ?? this.preset,
        mode: mode ?? this.mode,
      );

  static const defaults = ThemeSettings(
    preset: ThemePreset.moe,
    mode: ThemeMode.system,
  );
}

/// 持久化 + 通知
class ThemeController extends Notifier<ThemeSettings> {
  static const _kPreset = 'theme_preset';
  static const _kMode = 'theme_mode';

  @override
  ThemeSettings build() => ThemeSettings.defaults;

  /// 主入口预加载：消除启动时的"默认主题 → 用户主题"闪烁
  /// [main.dart] 在 runApp 之前 await 此方法
  Future<void> initialize() async {
    final p = await SharedPreferences.getInstance();
    final presetId = p.getString(_kPreset);
    final modeIdx = p.getInt(_kMode);
    state = ThemeSettings(
      preset: ThemePreset.fromId(presetId),
      // 边界检查：modeIdx 可能因版本/损坏数据越界
      mode: (modeIdx != null &&
              modeIdx >= 0 &&
              modeIdx < ThemeMode.values.length)
          ? ThemeMode.values[modeIdx]
          : ThemeMode.system,
    );
  }

  Future<void> setPreset(ThemePreset preset) async {
    state = state.copyWith(preset: preset);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kPreset, preset.id);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kMode, mode.index);
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeSettings>(ThemeController.new);
