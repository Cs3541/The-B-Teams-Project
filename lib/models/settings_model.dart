import 'package:flutter/material.dart';

enum BackgroundColor {
  defaultColor('Default', Color(0xFFFEF7FF)),
  white('White', Colors.white),
  blue('Light blue', Color(0xFFE3F2FD)),
  green('Light green', Color(0xFFE8F5E9)),
  pink('Light pink', Color(0xFFFCE4EC));

  final String label;
  final Color color;

  const BackgroundColor(this.label, this.color);
}
