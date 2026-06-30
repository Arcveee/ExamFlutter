import 'dart:convert';
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

  Future<Map<String, dynamic>> getWallet(String phone) async {
    final response = await client.get(Uri.parse('$baseUrl/api/wallets/$phone'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('status:${response.statusCode}');
    }
  }

  Future<List<dynamic>> getTransactions(String phone) async {
    final response = await client.get(Uri.parse('$baseUrl/api/wallets/$phone/transactions'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('status:${response.statusCode}');
    }
  }

  Future<void> transfer(String fromPhone, String toPhone, double amount) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/wallets/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fromPhone': fromPhone,
        'toPhone': toPhone,
        'amount': amount,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  Future<dynamic> getBills(String provider) async {}

  Future<dynamic> payBills(List<String> billIds) async {}
}
