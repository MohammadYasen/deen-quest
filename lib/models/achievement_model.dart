import 'package:flutter/material.dart';

class AchievementItem {
  const AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementItem copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return AchievementItem(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
