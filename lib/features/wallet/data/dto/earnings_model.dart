import '../../domain/entities/earning_entities.dart';

class EarningsModel extends EarningsEntity {
  const EarningsModel({
    required super.dailyEarnings,
    required super.weeklyEarnings,
  });

  factory EarningsModel.fromFirestore(Map<String, dynamic> data) {
    if (data['dailyEarnings'] == null || data['weeklyEarnings'] == null) {
      throw const FormatException('Earnings document is missing required fields');
    }

    return EarningsModel(
      dailyEarnings: (data['dailyEarnings'] as num).toDouble(),
      weeklyEarnings: (data['weeklyEarnings'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'dailyEarnings': dailyEarnings,
    'weeklyEarnings': weeklyEarnings,
  };
}