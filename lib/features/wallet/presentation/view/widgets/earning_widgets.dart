import 'package:flutter/material.dart';

import '../../../domain/entities/earning_entities.dart';


class EarningWidgets extends StatelessWidget {
  final EarningsEntity earnings;

  const EarningWidgets({
    super.key,
    required this.earnings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Performance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildEarningCard(
              icon: Icons.trending_up,
              label: 'Today\'s Earnings',
              amount: '${earnings.dailyEarnings.toStringAsFixed(0)} EGP',
            ),
            _buildEarningCard(
              icon: Icons.calendar_today,
              label: 'Weekly Earnings',
              amount: '${earnings.weeklyEarnings.toStringAsFixed(0)} EGP',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningCard({
    required IconData icon,
    required String label,
    required String amount,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.teal,
              size: 28,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

