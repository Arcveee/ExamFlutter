import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'bills_provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final _storage = const FlutterSecureStorage();
  String _myPhone = '';
  String? _selectedProvider;

  final List<Map<String, dynamic>> _providers = [
    {'code': 'ISM', 'name': 'ISM', 'icon': Icons.school, 'color': Colors.blue},
    {'code': 'WOYAFAL', 'name': 'Woyafal', 'icon': Icons.bolt, 'color': Colors.orange},
    {'code': 'RAPIDO', 'name': 'Rapido', 'icon': Icons.directions_car, 'color': Colors.green},
    {'code': 'SENELEC', 'name': 'Senelec', 'icon': Icons.power, 'color': Colors.yellow},
  ];

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final phone = await _storage.read(key: 'phone');
    if (mounted && phone != null) {
      _myPhone = phone;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BillsProvider>().reset();
    });
  }

  void _selectProvider(String code) {
    setState(() => _selectedProvider = code);
    context.read<BillsProvider>().fetchBills(code, _myPhone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement de factures'),
        leading: _selectedProvider != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _selectedProvider = null);
                  context.read<BillsProvider>().reset();
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Consumer<BillsProvider>(
          builder: (context, provider, child) {
            if (provider.state is BillsPaymentSuccess) {
              return _buildSuccess(context);
            }

            if (provider.state is BillsError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text((provider.state as BillsError).message)),
                );
                provider.reset();
                setState(() => _selectedProvider = null);
              });
            }

            if (_selectedProvider == null) {
              return _buildProviderGrid();
            }

            return _buildBillsList(provider);
          },
        ),
      ),
    );
  }

  Widget _buildProviderGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        final p = _providers[index];
        return GestureDetector(
          onTap: () => _selectProvider(p['code']),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(p['icon'], size: 48, color: p['color']),
                const SizedBox(height: 16),
                Text(p['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillsList(BillsProvider provider) {
    if (provider.state is BillsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state is BillsLoaded || provider.state is BillsPaymentLoading) {
      final bills = provider.state is BillsLoaded
          ? (provider.state as BillsLoaded).bills
          : (provider.state as BillsPaymentLoading).bills;

      if (bills.isEmpty) {
        return const Center(child: Text('Aucune facture impayée trouvée.', style: TextStyle(color: AppColors.textHint)));
      }

      double total = 0;
      for (var b in bills) {
        if (provider.selectedBills.contains(b.reference)) {
          total += b.amount;
        }
      }

      final isPaying = provider.state is BillsPaymentLoading;

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                final isSelected = provider.selectedBills.contains(bill.reference);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: isPaying ? null : (_) => provider.toggleSelection(bill.reference),
                    title: Text(bill.reference, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Échéance : ${Formatter.relativeDate(bill.dueDate)}'),
                    secondary: Text(Formatter.currency(bill.amount),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    activeColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.bgCard,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total à payer', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                    Text(Formatter.currency(total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.selectedBills.isEmpty || isPaying ? null : () => provider.paySelectedBills(_myPhone, _selectedProvider!),
                    child: isPaying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Payer la sélection (${provider.selectedBills.length})'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSuccess(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: AppColors.success),
          const SizedBox(height: 24),
          const Text('Paiement réussi !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Retour au Dashboard'),
          ),
        ],
      ),
    );
  }
}
