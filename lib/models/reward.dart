import 'package:flutter/material.dart';

class Reward {
  final String title;
  final String points;
  final IconData icon;
  final Color color;
  double _progress;

  Reward({
    required this.title,
    required double progress,
    required this.points,
    required this.icon,
    required this.color,
  }) : _progress = progress;

  double get progress => _progress;

  set progress(double value) {
    _progress = value;
  }
}
