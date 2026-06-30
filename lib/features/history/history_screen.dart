import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'history_provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = const FlutterSecureStorage();
  String _myPhone = '';

  final List<String> _filters = ['Tous', 'Dépôts', 'Retraits', 'Transferts', 'Paiements'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final phone = await _storage.read(key: 'phone');
    if (mounted && phone != null) {
      _myPhone = phone;
      context.read<HistoryProvider>().fetchHistory(_myPhone);
    }
  }

  void _showTransactionDetails(Transaction tx, bool isIncoming, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Icon(
                isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
                color: color,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                '${isIncoming ? '+' : '-'} ${Formatter.currency(tx.amount)}',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Succès', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              _buildDetailRow('Type', tx.type),
              const SizedBox(height: 16),
              _buildDetailRow('Date', Formatter.fullDate(tx.date)),
              const SizedBox(height: 16),
              _buildDetailRow('Frais', '0 XOF'),
              const SizedBox(height: 16),
              _buildDetailRow('De', tx.fromPhone),
              const SizedBox(height: 16),
              _buildDetailRow('À', tx.toPhone),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
      ),
      body: SafeArea(
        child: Consumer<HistoryProvider>(
          builder: (context, provider, child) {
            if (provider.state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.state is HistoryError) {
              return Center(
                child: ElevatedButton(
                  onPressed: _loadHistory,
                  child: const Text('Réessayer'),
                ),
              );
            }

            if (provider.state is HistoryLoaded) {
              final state = provider.state as HistoryLoaded;

              return Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = state.selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (_) => provider.setFilter(filter),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.bgSurface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: state.filteredTransactions.isEmpty
                        ? const Center(child: Text('Aucune transaction trouvée.', style: TextStyle(color: AppColors.textHint)))
                        : RefreshIndicator(
                            onRefresh: _loadHistory,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final tx = state.filteredTransactions[index];
                                final isIncoming = tx.toPhone == _myPhone;
                                final color = isIncoming ? AppColors.success : AppColors.error;
                                final prefix = isIncoming ? '+' : '-';

                                return GestureDetector(
                                  onTap: () => _showTransactionDetails(tx, isIncoming, color),
                                  child: Container(
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
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
