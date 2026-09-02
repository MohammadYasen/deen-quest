import 'package:flutter/material.dart';

class ChallengeItem {
  const ChallengeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.targetValue,
    required this.currentValue,
    this.isCompleted = false,
    this.isClaimed = false,
    this.isWeekly = false,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final String reward;
  final int targetValue;
  final int currentValue;
  final bool isCompleted;
  final bool isClaimed;
  final bool isWeekly;
  final IconData icon;
  final Color color;

  double get progress => targetValue == 0 ? 0.0 : (currentValue / targetValue).clamp(0.0, 1.0);

  ChallengeItem copyWith({
    int? currentValue,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return ChallengeItem(
      id: id,
      title: title,
      description: description,
      reward: reward,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      isWeekly: isWeekly,
      icon: icon,
      color: color,
    );
  }
}
