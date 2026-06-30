import 'package:http/http.dart' as http;
import '../constants.dart';

class WalletApiClient {
  static final WalletApiClient _instance = WalletApiClient._internal();

  factory WalletApiClient() {
    return _instance;
  }

  WalletApiClient._internal();

  final http.Client client = http.Client();
  final String baseUrl = Constants.baseUrl;

  Future<dynamic> getWallet(String phone) async {}

  Future<dynamic> getTransactions(String phone) async {}

  Future<dynamic> transfer(String fromPhone, String toPhone, double amount) async {}

  Future<dynamic> getBills(String provider) async {}

  Future<dynamic> payBills(List<String> billIds) async {}
}
