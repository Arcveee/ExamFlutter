import 'package:flutter/material.dart';
import '../../core/repositories/wallet_repository.dart';
import '../dashboard/dashboard_provider.dart';
import '../../models/bill.dart';

abstract class BillsState {}

class BillsInitial extends BillsState {}
class BillsLoading extends BillsState {}
class BillsLoaded extends BillsState {
  final List<Bill> bills;
  BillsLoaded(this.bills);
}
class BillsPaymentLoading extends BillsState {
  final List<Bill> bills;
  BillsPaymentLoading(this.bills);
}
class BillsPaymentSuccess extends BillsState {}
class BillsError extends BillsState {
  final String message;
  BillsError(this.message);
}

class BillsProvider extends ChangeNotifier {
  final WalletRepository repository;
  final DashboardProvider dashboardProvider;
  BillsState state = BillsInitial();
  Set<String> selectedBills = {};

  BillsProvider(this.repository, this.dashboardProvider);

  Future<void> fetchBills(String code, String phone) async {
    state = BillsLoading();
    selectedBills.clear();
    notifyListeners();

    try {
      final bills = await repository.getBills(code, phone);
      state = BillsLoaded(bills);
      notifyListeners();
    } catch (e) {
      state = BillsError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
    }
  }

  void toggleSelection(String reference) {
    if (selectedBills.contains(reference)) {
      selectedBills.remove(reference);
    } else {
      selectedBills.add(reference);
    }
    notifyListeners();
  }

  Future<void> paySelectedBills(String phone) async {
    if (state is BillsLoaded) {
      final currentBills = (state as BillsLoaded).bills;
      state = BillsPaymentLoading(currentBills);
      notifyListeners();

      try {
        await repository.payBills(phone, selectedBills.toList());
        state = BillsPaymentSuccess();
        dashboardProvider.loadDashboard(phone);
        notifyListeners();
      } catch (e) {
        state = BillsError(e.toString().replaceAll('Exception: ', ''));
        notifyListeners();
      }
    }
  }

  void reset() {
    state = BillsInitial();
    selectedBills.clear();
    notifyListeners();
  }
}
