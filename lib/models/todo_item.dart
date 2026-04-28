import 'package:uuid/uuid.dart';

class TodoItem {
  final String id;
  String title;
  double cost;
  String bankId;
  bool completed;
  DateTime? completedAt;
  String? linkedTransactionId;
  final DateTime createdAt;

  TodoItem({
    String? id,
    required this.title,
    required this.cost,
    required this.bankId,
    this.completed = false,
    this.completedAt,
    this.linkedTransactionId,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'cost': cost,
        'bankId': bankId,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
        'linkedTransactionId': linkedTransactionId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'],
        title: json['title'] ?? '',
        cost: (json['cost'] as num).toDouble(),
        bankId: json['bankId'] ?? '',
        completed: json['completed'] ?? false,
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        linkedTransactionId: json['linkedTransactionId'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
