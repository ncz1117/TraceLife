import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color moodVerySad;
  final Color moodSad;
  final Color moodNeutral;
  final Color moodHappy;
  final Color moodVeryHappy;

  const AppColors({
    required this.moodVerySad,
    required this.moodSad,
    required this.moodNeutral,
    required this.moodHappy,
    required this.moodVeryHappy,
  });

  static const light = AppColors(
    moodVerySad: Color(0xFF6366F1),
    moodSad: Color(0xFF818CF8),
    moodNeutral: Color(0xFF9CA3AF),
    moodHappy: Color(0xFFFBBF24),
    moodVeryHappy: Color(0xFFF97316),
  );

  static const dark = AppColors(
    moodVerySad: Color(0xFF818CF8),
    moodSad: Color(0xFFA5B4FC),
    moodNeutral: Color(0xFF6B7280),
    moodHappy: Color(0xFFFCD34D),
    moodVeryHappy: Color(0xFFFB923C),
  );

  @override
  AppColors copyWith({
    Color? moodVerySad,
    Color? moodSad,
    Color? moodNeutral,
    Color? moodHappy,
    Color? moodVeryHappy,
  }) {
    return AppColors(
      moodVerySad: moodVerySad ?? this.moodVerySad,
      moodSad: moodSad ?? this.moodSad,
      moodNeutral: moodNeutral ?? this.moodNeutral,
      moodHappy: moodHappy ?? this.moodHappy,
      moodVeryHappy: moodVeryHappy ?? this.moodVeryHappy,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      moodVerySad: Color.lerp(moodVerySad, other.moodVerySad, t)!,
      moodSad: Color.lerp(moodSad, other.moodSad, t)!,
      moodNeutral: Color.lerp(moodNeutral, other.moodNeutral, t)!,
      moodHappy: Color.lerp(moodHappy, other.moodHappy, t)!,
      moodVeryHappy: Color.lerp(moodVeryHappy, other.moodVeryHappy, t)!,
    );
  }
}
