import '../api/wallet_api_client.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';
import '../../models/bill.dart';

class WalletRepository {
  final WalletApiClient apiClient;

  WalletRepository(this.apiClient);

  Future<Wallet> getWallet(String phone) async {
    throw UnimplementedError();
  }

  Future<List<Transaction>> getTransactions(String phone) async {
    throw UnimplementedError();
  }

  Future<void> transfer(String fromPhone, String toPhone, double amount) async {
    throw UnimplementedError();
  }

  Future<List<Bill>> getBills(String provider) async {
    throw UnimplementedError();
  }

  Future<void> payBills(List<String> billIds) async {
    throw UnimplementedError();
  }
}
