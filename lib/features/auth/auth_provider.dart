import 'package:flutter/material.dart';
import '../../core/repositories/wallet_repository.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String phone;
  final int walletId;
  AuthSuccess(this.phone, this.walletId);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthProvider extends ChangeNotifier {
  final WalletRepository repository;
  AuthState state = AuthInitial();

  AuthProvider(this.repository);

  Future<void> verifyPhone(String phone) async {
    state = AuthLoading();
    notifyListeners();

    try {
      final wallet = await repository.getWallet(phone);
      state = AuthSuccess(phone, wallet.id);
      notifyListeners();
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('404')) {
        state = AuthError('Ce numéro ne correspond à aucun wallet. Veuillez contacter un agent.');
      } else {
        state = AuthError(msg.replaceAll('Exception: ', ''));
      }
      notifyListeners();
    }
  }

  void reset() {
    state = AuthInitial();
    notifyListeners();
  }
}
