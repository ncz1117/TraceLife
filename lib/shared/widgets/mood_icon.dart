import 'package:flutter/material.dart';

class MoodIcon extends StatelessWidget {
  final int mood;
  final double size;

  const MoodIcon({
    super.key,
    required this.mood,
    this.size = 24,
  });

  static const _emojis = ['😢', '😕', '😐', '🙂', '😄'];

  String get emoji => _emojis[mood.clamp(1, 5) - 1];
  String get label {
    const labels = ['很差', '不好', '一般', '不错', '很好'];
    return labels[mood.clamp(1, 5) - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Text(emoji, style: TextStyle(fontSize: size));
  }
}
