import 'package:flutter/material.dart';
import '../../core/repositories/wallet_repository.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String phone;
  AuthSuccess(this.phone);
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
      final formattedPhone = phone.startsWith('+') ? phone.substring(1) : phone;
      await repository.getWallet(formattedPhone);
      state = AuthSuccess(phone);
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('404')) {
        state = AuthError('Ce numéro ne correspond à aucun wallet. Veuillez contacter un agent.');
      } else {
        state = AuthError('Erreur de connexion au serveur.');
      }
      notifyListeners();
    }
  }
}
