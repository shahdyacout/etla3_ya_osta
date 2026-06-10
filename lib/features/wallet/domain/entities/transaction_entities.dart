enum TransactionType { income, expense }

class TransactionEntity {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  String get formattedAmount {
    final sign = type == TransactionType.income ? '+' : '-';
    return '$sign${amount.toStringAsFixed(0)} EGP';
  }
}