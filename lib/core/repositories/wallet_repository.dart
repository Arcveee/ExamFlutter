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
    final content = data['content'] as List<dynamic>;
    return content.map((json) => Transaction.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> transfer(String fromPhone, String toPhone, double amount) async {
    await apiClient.transfer(fromPhone, toPhone, amount);
  }

  Future<List<Bill>> getBills(String code, String phone) async {
    final data = await apiClient.getBills(code, phone);
    return data.map((json) => Bill.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> payBills(String phone, String serviceName, List<String> billIds) async {
    await apiClient.payBills(phone, serviceName, billIds);
  }
}
