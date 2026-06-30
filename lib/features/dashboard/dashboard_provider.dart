import 'package:flutter/material.dart';
import '../../core/repositories/wallet_repository.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Wallet wallet;
  final List<Transaction> recentTransactions;
  final bool isBalanceHidden;

  DashboardLoaded(this.wallet, this.recentTransactions, {this.isBalanceHidden = false});
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}

class DashboardProvider extends ChangeNotifier {
  final WalletRepository repository;
  DashboardState state = DashboardInitial();

  DashboardProvider(this.repository);

  void toggleBalanceVisibility() {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      state = DashboardLoaded(
        currentState.wallet,
        currentState.recentTransactions,
        isBalanceHidden: !currentState.isBalanceHidden,
      );
      notifyListeners();
    }
  }

  Future<void> loadDashboard(String phone) async {
    state = DashboardLoading();
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getWallet(phone),
        repository.getTransactions(phone),
      ]);

      final wallet = results[0] as Wallet;
      final allTransactions = results[1] as List<Transaction>;

      allTransactions.sort((a, b) => b.date.compareTo(a.date));
      final recent = allTransactions.take(5).toList();

      state = DashboardLoaded(wallet, recent);
      notifyListeners();
    } catch (e) {
      state = DashboardError('Erreur de chargement. Veuillez réessayer.');
      notifyListeners();
    }
  }
}
