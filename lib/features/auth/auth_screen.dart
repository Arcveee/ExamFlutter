import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_provider.dart';
import '../../core/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+221';
  }

  void _verify() {
    final phone = _phoneController.text.trim();
    if (phone.length == 13) {
      context.read<AuthProvider>().verifyPhone(phone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format de numéro invalide')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.state is AuthSuccess) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final success = authProvider.state as AuthSuccess;
                  await _storage.write(key: 'phone', value: success.phone);
                  await _storage.write(key: 'walletId', value: success.walletId.toString());
                  if (context.mounted) {
                    context.go('/pin-setup');
                  }
                });
              }

              if (authProvider.state is AuthError) {
                final error = (authProvider.state as AuthError).message;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                  authProvider.state = AuthInitial();
                });
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.account_circle, size: 80, color: AppColors.primary),
                  const SizedBox(height: 32),
                  const Text(
                    'Bienvenue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entrez votre numéro pour continuer',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 48),
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
                        _phoneController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _phoneController.text.length),
                        );
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      hintText: '+221XXXXXXXXX',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authProvider.state is AuthLoading ? null : _verify,
                    child: authProvider.state is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Valider'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
