import 'package:uuid/uuid.dart';

class Goal {
  final String id;
  String title;
  double targetAmount;
  double savedAmount;
  DateTime? deadline;
  final DateTime createdAt;

  Goal({
    String? id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    this.deadline,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get progress {
    if (targetAmount <= 0) return 0;
    return (savedAmount / targetAmount).clamp(0.0, 1.0);
  }

  bool get isComplete => savedAmount >= targetAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'deadline': deadline?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        title: json['title'] ?? '',
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
        deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
        createdAt: DateTime.parse(json['createdAt']),
      );
}
