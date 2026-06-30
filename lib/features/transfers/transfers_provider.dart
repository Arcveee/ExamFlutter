import 'package:flutter/material.dart';
import '../../core/repositories/wallet_repository.dart';
import '../dashboard/dashboard_provider.dart';

abstract class TransferState {}

class TransferInitial extends TransferState {}
class TransferLoading extends TransferState {}
class TransferSuccess extends TransferState {}
class TransferError extends TransferState {
  final String message;
  TransferError(this.message);
}

class TransfersProvider extends ChangeNotifier {
  final WalletRepository repository;
  final DashboardProvider dashboardProvider;
  TransferState state = TransferInitial();

  TransfersProvider(this.repository, this.dashboardProvider);

  Future<void> executeTransfer(String fromPhone, String toPhone, double amount) async {
    state = TransferLoading();
    notifyListeners();
    try {
      await repository.transfer(fromPhone, toPhone, amount);
      state = TransferSuccess();
      dashboardProvider.loadDashboard(fromPhone);
      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('insufficient') || msg.contains('solde')) {
        state = TransferError('Solde insuffisant.');
      } else if (msg.contains('not found') || msg.contains('introuvable')) {
        state = TransferError('Destinataire introuvable.');
      } else if (msg.contains('connexion') || msg.contains('délai')) {
        state = TransferError(e.toString().replaceAll('Exception: ', ''));
      } else {
        state = TransferError('Échec du transfert.');
      }
      notifyListeners();
    }
  }

  void reset() {
    state = TransferInitial();
    notifyListeners();
  }
}
