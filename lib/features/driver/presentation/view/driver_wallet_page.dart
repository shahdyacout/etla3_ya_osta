import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../../wallet/presentation/cubit/wallet_state.dart';
import '../../../wallet/presentation/view/widgets/balance_card.dart';
import '../../../wallet/presentation/view/widgets/earning_widgets.dart';
import '../../../wallet/presentation/view/widgets/withdraw_bottom_sheet.dart';

class DriverWalletPage extends StatefulWidget {
  const DriverWalletPage({super.key});

  @override
  State<DriverWalletPage> createState() => _DriverWalletPageState();
}

class _DriverWalletPageState extends State<DriverWalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().getBalance();
    context.read<WalletCubit>().getEarnings();
    context.read<WalletCubit>().getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    const Color primarySage = Color(0xFF9BB59A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Driver Wallet',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.wallet != null)
                      BalanceCard(wallet: state.wallet!),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    _buildQuickStats(state, isSmallScreen, primarySage),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    if (state.earnings != null)
                      EarningWidgets(earnings: state.earnings!),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    _buildTransactionSection(state, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: state.isWithdrawing
                            ? null
                            : () => _showWithdrawSheet(context, state),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primarySage,
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: state.isWithdrawing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Withdraw Funds',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(WalletState state, bool isSmallScreen, Color primarySage) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(
            icon: Icons.account_balance_wallet_outlined,
            value: state.wallet?.balance.toStringAsFixed(0) ?? '0',
            label: 'Balance',
            color: primarySage,
            isSmallScreen: isSmallScreen,
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatColumn(
            icon: Icons.trending_up,
            value: state.earnings?.dailyEarnings.toStringAsFixed(0) ?? '0',
            label: 'Today',
            color: Colors.green,
            isSmallScreen: isSmallScreen,
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatColumn(
            icon: Icons.shield,
            value: state.wallet?.insuranceDeposit.toStringAsFixed(0) ?? '0',
            label: 'Insurance',
            color: Colors.teal[700]!,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: isSmallScreen ? 22 : 26),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2F4054),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionSection(WalletState state, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F4054),
            ),
          ),
          const SizedBox(height: 12),
          if (state.transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No transactions yet',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...state.transactions.take(5).map(
              (transaction) => _buildTransactionItem(
                transaction.title,
                transaction.formattedAmount,
                transaction.date,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, DateTime date) {
    final isIncome = amount.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2F4054),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
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
