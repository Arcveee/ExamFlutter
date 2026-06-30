import 'package:flutter/material.dart';
import '../../core/repositories/wallet_repository.dart';
import '../../models/transaction.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}
class HistoryLoading extends HistoryState {}
class HistoryLoaded extends HistoryState {
  final List<Transaction> allTransactions;
  final List<Transaction> filteredTransactions;
  final String selectedFilter;

  HistoryLoaded(this.allTransactions, this.filteredTransactions, this.selectedFilter);
}
class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

class HistoryProvider extends ChangeNotifier {
  final WalletRepository repository;
  HistoryState state = HistoryInitial();

  HistoryProvider(this.repository);

  Future<void> fetchHistory(String phone) async {
    state = HistoryLoading();
    notifyListeners();

    try {
      final transactions = await repository.getTransactions(phone);
      transactions.sort((a, b) => b.date.compareTo(a.date));
      state = HistoryLoaded(transactions, transactions, 'Tous');
      notifyListeners();
    } catch (e) {
      state = HistoryError('Erreur de chargement.');
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (state is HistoryLoaded) {
      final current = state as HistoryLoaded;
      List<Transaction> filtered;

      if (filter == 'Tous') {
        filtered = current.allTransactions;
      } else {
        filtered = current.allTransactions.where((tx) {
          final t = tx.type.toLowerCase();
          if (filter == 'Dépôts') return t.contains('deposit') || t.contains('dépôt');
          if (filter == 'Retraits') return t.contains('withdraw') || t.contains('retrait');
          if (filter == 'Transferts') return t.contains('transfer');
          if (filter == 'Paiements') return t.contains('payment') || t.contains('paiement') || t.contains('facture');
          return false;
        }).toList();
      }

      state = HistoryLoaded(current.allTransactions, filtered, filter);
      notifyListeners();
    }
  }
}
