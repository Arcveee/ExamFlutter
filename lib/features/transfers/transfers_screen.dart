import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'transfers_provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../shared/numeric_keypad.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  int _step = 0;
  final _phoneController = TextEditingController(text: '+221');
  String _amountString = '';
  String _myPhone = '';
  final _storage = const FlutterSecureStorage();

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
      if (mounted) context.read<TransfersProvider>().reset();
    });
  }

  void _nextStep() {
    if (_step == 0) {
      final recipient = _phoneController.text.trim();
      if (recipient.length == 13 && recipient != _myPhone) {
        setState(() => _step = 1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Numéro invalide ou identique au vôtre')),
        );
      }
    } else if (_step == 1) {
      final amount = double.tryParse(_amountString) ?? 0;
      if (amount >= 100) {
        setState(() => _step = 2);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le montant minimum est de 100 FCFA')),
        );
      }
    }
  }

  void _confirmTransfer(TransfersProvider provider) {
    final amount = double.tryParse(_amountString) ?? 0;
    provider.executeTransfer(_myPhone, _phoneController.text.trim(), amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert'),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step--),
              )
            : null,
      ),
      body: SafeArea(
        child: Consumer<TransfersProvider>(
          builder: (context, provider, child) {
            if (provider.state is TransferSuccess) {
              return _buildSuccess(context);
            }

            if (provider.state is TransferError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text((provider.state as TransferError).message)),
                );
                provider.reset();
              });
            }

            if (_step == 0) return _buildStep1();
            if (_step == 1) return _buildStep2();
            return _buildStep3(provider);
          },
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('À qui envoyez-vous de l\'argent ?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[+0-9]*$')),
              LengthLimitingTextInputFormatter(13),
            ],
            onChanged: (value) {
              if (!value.startsWith('+221')) {
                _phoneController.text = '+221';
                _phoneController.selection = TextSelection.fromPosition(TextPosition(offset: _phoneController.text.length));
              }
              setState(() {});
            },
            decoration: const InputDecoration(labelText: 'Numéro du destinataire', prefixIcon: Icon(Icons.phone)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _phoneController.text.length == 13 ? _nextStep : null,
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final amount = double.tryParse(_amountString) ?? 0;
    return Column(
      children: [
        const SizedBox(height: 48),
        const Text('Montant à envoyer', style: TextStyle(fontSize: 20, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Text(
          Formatter.currency(amount),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const Spacer(),
        NumericKeypad(
          onKeyPress: (key) => setState(() {
            if (_amountString.length < 7) _amountString += key;
          }),
          onDelete: () {
            if (_amountString.isNotEmpty) {
              setState(() => _amountString = _amountString.substring(0, _amountString.length - 1));
            }
          },
          onValidate: _nextStep,
          isValid: amount >= 100,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep3(TransfersProvider provider) {
    final amount = double.tryParse(_amountString) ?? 0;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 80, color: AppColors.accent),
          const SizedBox(height: 32),
          const Text('Confirmation', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildSummaryRow('Destinataire', _phoneController.text),
          const SizedBox(height: 16),
          _buildSummaryRow('Montant', Formatter.currency(amount)),
          const SizedBox(height: 16),
          _buildSummaryRow('Frais', '0 XOF'),
          const Divider(height: 48),
          _buildSummaryRow('Total', Formatter.currency(amount)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: provider.state is TransferLoading ? null : () => _confirmTransfer(provider),
            child: provider.state is TransferLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Confirmer le transfert'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: AppColors.success),
          const SizedBox(height: 24),
          const Text('Transfert réussi !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Vous avez envoyé ${Formatter.currency(double.parse(_amountString))} à ${_phoneController.text}'),
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
