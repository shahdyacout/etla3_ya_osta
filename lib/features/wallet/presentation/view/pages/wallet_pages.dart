import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/wallet_cubit.dart';
import '../../cubit/wallet_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/earning_widgets.dart';
import '../widgets/transaction_title.dart';
import '../widgets/withdraw_bottom_sheet.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().getBalance();
    context.read<WalletCubit>().getEarnings();
    context.read<WalletCubit>().getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Wallet & Security'),
        elevation: 0,
      ),
      body: BlocListener<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<WalletCubit>().getBalance();
            context.read<WalletCubit>().getEarnings();
            context.read<WalletCubit>().getTransactions();
          },
          child: BlocBuilder<WalletCubit, WalletState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    if (state.wallet != null)
                      BalanceCard(wallet: state.wallet!),
                    const SizedBox(height: 24),

                    // Insurance Deposit Card
                    _buildInsuranceCard(state),
                    const SizedBox(height: 24),

                    // Earnings Stats
                    if (state.earnings != null)
                      EarningWidgets(earnings: state.earnings!),
                    const SizedBox(height: 24),

                    // Transaction History
                    const TransactionTitle(),
                    const SizedBox(height: 12),

                    if (state.transactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No transactions yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: state.transactions
                            .map(
                              (transaction) => _buildTransactionItem(
                            context,
                            transaction.title,
                            transaction.formattedAmount,
                            transaction.date,
                          ),
                        )
                            .toList(),
                      ),

                    const SizedBox(height: 24),

                    // Withdraw Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isWithdrawing
                            ? null
                            : () => _showWithdrawSheet(context, state),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF6B9B7F),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: state.isWithdrawing
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                            : const Text(
                          'Withdraw Funds',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInsuranceCard(WalletState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield, color: Colors.teal[700], size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Insurance Deposit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Assurance & Security',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${state.wallet?.insuranceDeposit.toStringAsFixed(0) ?? '0'} ${state.wallet?.currency ?? 'EGP'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Your insurance deposit is protected and will be returned when you complete your contract period.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context,
      String title,
      String amount,
      DateTime date,
      ) {
    final isIncome = amount.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isIncome ? Icons.trending_up : Icons.trending_down,
                color: isIncome ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
                        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context, WalletState state) {
    final cubit = context.read<WalletCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: WithdrawBottomSheet(
          maxAmount: state.wallet?.balance ?? 0,
          currency: state.wallet?.currency ?? 'EGP',
        ),
      ),
    );
  }
}
