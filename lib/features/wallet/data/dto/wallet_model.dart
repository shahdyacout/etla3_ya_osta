import '../../domain/entities/wallet_entities.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.balance,
    required super.insuranceDeposit,
    required super.currency,
  });

  factory WalletModel.fromFirestore(Map<String, dynamic> data) {
    return WalletModel(
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      insuranceDeposit: (data['insuranceDeposit'] as num?)?.toDouble() ?? 0.0,
      currency: (data['currency'] as String?) ?? 'EGP',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'balance': balance,
    'insuranceDeposit': insuranceDeposit,
    'currency': currency,
  };
}
