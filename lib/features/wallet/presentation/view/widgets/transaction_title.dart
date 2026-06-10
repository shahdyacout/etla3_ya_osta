import 'package:flutter/material.dart';

class TransactionTitle extends StatelessWidget {
  const TransactionTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Transaction History',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

