import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String bankId;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? note;

  Transaction({
    String? id,
    required this.bankId,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note,
  }) : id = id ?? const Uuid().v4();

  // For easy state management and persistence
  Map<String, dynamic> toJson() => {
    'id': id,
    'bankId': bankId,
    'amount': amount,
    'category': category,
    'type': type.index,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    bankId: json['bankId'],
    amount: json['amount'],
    category: json['category'],
    type: TransactionType.values[json['type']],
    date: DateTime.parse(json['date']),
    note: json['note'],
  );
}
