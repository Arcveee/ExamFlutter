import '../api/wallet_api_client.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';
import '../../models/bill.dart';

class WalletRepository {
  final WalletApiClient apiClient;

  WalletRepository(this.apiClient);

  Future<Wallet> getWallet(String phone) async {
    final data = await apiClient.getWallet(phone);
    return Wallet.fromJson(data);
  }

  Future<List<Transaction>> getTransactions(String phone) async {
    final data = await apiClient.getTransactions(phone);
    return data.map((json) => Transaction.fromJson(json as Map<String, dynamic>)).toList();
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
