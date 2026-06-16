import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entities.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.type,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      throw const FormatException('Transaction document is empty or missing');
    }

    final data = doc.data() as Map<String, dynamic>;

    if (data['amount'] == null || data['date'] == null) {
      throw FormatException(
        'Transaction ${doc.id} is missing required fields',
      );
    }

    return TransactionModel(
      id: doc.id,
      title: data['title'] as String? ?? 'معاملة غير معروفة',
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      type: (data['type'] as String?) == 'expense'
          ? TransactionType.expense
          : TransactionType.income,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'type': type == TransactionType.income ? 'income' : 'expense',
  };
}