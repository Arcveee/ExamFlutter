import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dashboard_provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storage = const FlutterSecureStorage();
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    final phone = await _storage.read(key: 'phone');
    if (phone != null && mounted) {
      _phone = phone;
      context.read<DashboardProvider>().loadDashboard(_phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BadWallet'),
        elevation: 0,
        backgroundColor: AppColors.bgSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () async {
              await _storage.deleteAll();
              if (context.mounted) {
                context.go('/auth');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.state is DashboardLoading || provider.state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.state is DashboardError) {
              final error = (provider.state as DashboardError).message;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(error, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadDashboard(_phone),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (provider.state is DashboardLoaded) {
              final state = provider.state as DashboardLoaded;
              return RefreshIndicator(
                onRefresh: () => provider.loadDashboard(_phone),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(state, provider),
                        const SizedBox(height: 32),
                        _buildActionButtons(context),
                        const SizedBox(height: 32),
                        const Text(
                          'Transactions récentes',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildTransactionsList(state),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(DashboardLoaded state, DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Solde actuel', style: TextStyle(color: AppColors.textSecondary)),
              IconButton(
                icon: Icon(
                  state.isBalanceHidden ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textHint,
                ),
                onPressed: provider.toggleBalanceVisibility,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.isBalanceHidden ? '•••••• FCFA' : Formatter.currency(state.wallet.balance),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(Icons.send, 'Transférer', () => context.go('/transfers')),
        _buildActionButton(Icons.receipt_long, 'Payer', () => context.go('/bills')),
        _buildActionButton(Icons.history, 'Historique', () => context.go('/history')),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(DashboardLoaded state) {
    if (state.recentTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text('Aucune transaction récente', style: TextStyle(color: AppColors.textHint)),
        ),
      );
    }

    return Column(
      children: state.recentTransactions.map((tx) {
        final isIncoming = tx.targetWalletId == state.wallet.id;
        final color = isIncoming ? AppColors.success : AppColors.error;
        final prefix = isIncoming ? '+' : '-';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.type,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatter.relativeDate(tx.date),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                '$prefix ${Formatter.currency(tx.amount)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
