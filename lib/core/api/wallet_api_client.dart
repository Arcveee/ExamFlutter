import 'dart:convert';
import 'dart:async';
import 'dart:io';
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

  Future<http.Response> _executeRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw Exception('status:${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw Exception('Aucune connexion Internet. Veuillez vérifier votre réseau.');
    } on TimeoutException {
      throw Exception('Délai d\'attente dépassé. Le serveur met trop de temps à répondre.');
    }
  }

  Future<Map<String, dynamic>> getWallet(String phone) async {
    final response = await _executeRequest(() => client.get(Uri.parse('$baseUrl/api/wallets/$phone')));
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTransactions(String phone) async {
    final response = await _executeRequest(() => client.get(Uri.parse('$baseUrl/api/wallets/$phone/transactions')));
    return json.decode(response.body) as List<dynamic>;
  }

  Future<void> transfer(String fromPhone, String toPhone, double amount) async {
    await _executeRequest(() => client.post(
          Uri.parse('$baseUrl/api/wallets/transfer'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'fromPhone': fromPhone,
            'toPhone': toPhone,
            'amount': amount,
          }),
        ));
  }

  Future<List<dynamic>> getBills(String code, String phone) async {
    final response = await _executeRequest(() => client.get(Uri.parse('$baseUrl/api/external/factures/$code/current?unite=$phone')));
    return json.decode(response.body) as List<dynamic>;
  }

  Future<void> payBills(String phone, List<String> billIds) async {
    await _executeRequest(() => client.post(
          Uri.parse('$baseUrl/api/wallets/pay-factures'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'phone': phone,
            'references': billIds,
          }),
        ));
  }
}
