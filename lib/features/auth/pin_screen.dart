import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;

  const PinScreen({super.key, required this.isSetup});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  final _storage = const FlutterSecureStorage();

  void _onKeyPress(String key) {
    if (_pin.length < 4) {
      setState(() {
        _pin += key;
      });
      if (_pin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _validatePin() async {
    if (widget.isSetup) {
      await _storage.write(key: 'pin', value: _pin);
      if (mounted) {
        context.go('/dashboard');
      }
    } else {
      final storedPin = await _storage.read(key: 'pin');
      if (_pin == storedPin) {
        if (mounted) {
          context.go('/dashboard');
        }
      } else {
        setState(() {
          _pin = '';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code PIN incorrect')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              widget.isSetup ? 'Configurez votre code PIN' : 'Saisissez votre code PIN',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length ? AppColors.primary : AppColors.border,
                  ),
                );
              }),
            ),
            const Spacer(),
            _buildKeypad(),
            if (widget.isSetup)
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Ignorer', style: TextStyle(color: AppColors.textSecondary)),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var j = 1; j <= 3; j++) _buildKey((i * 3 + j).toString()),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80),
              _buildKey('0'),
              _buildKey('del', isDelete: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value, {bool isDelete = false}) {
    return GestureDetector(
      onTap: () => isDelete ? _onDelete() : _onKeyPress(value),
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bgSurface,
        ),
        child: Center(
          child: isDelete
              ? const Icon(Icons.backspace, color: AppColors.textPrimary)
              : Text(
                  value,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
