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
        try {
          final body = json.decode(response.body);
          if (body is Map && body.containsKey('detail')) {
            throw Exception(body['detail']);
          } else if (body is Map && body.containsKey('message')) {
            throw Exception(body['message']);
          } else if (body is Map && body.containsKey('errors')) {
            throw Exception(body['errors'].toString());
          }
        } catch (e) {
          if (e.toString().startsWith('Exception:')) {
            rethrow;
          }
        }
        throw Exception('Erreur serveur (code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Aucune connexion Internet. Veuillez vérifier votre réseau.');
    } on TimeoutException {
      throw Exception('Délai d\'attente dépassé. Le serveur met trop de temps à répondre.');
    }
  }

  Future<Map<String, dynamic>> getWallet(String phone) async {
    final uri = Uri.parse(baseUrl).replace(pathSegments: ['api', 'wallets', phone]);
    final response = await _executeRequest(() => client.get(uri));
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTransactions(String phone) async {
    final uri = Uri.parse(baseUrl).replace(pathSegments: ['api', 'wallets', phone, 'transactions']);
    final response = await _executeRequest(() => client.get(uri));
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<void> transfer(String fromPhone, String toPhone, double amount) async {
    await _executeRequest(() => client.post(
          Uri.parse('$baseUrl/api/wallets/transfer'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'senderPhone': fromPhone,
            'receiverPhone': toPhone,
            'amount': amount,
          }),
        ));
  }

  Future<List<dynamic>> getBills(String code, String phone) async {
    final response = await _executeRequest(() => client.get(Uri.parse('$baseUrl/api/external/factures/$code/current')));
    return json.decode(response.body) as List<dynamic>;
  }

  Future<void> payBills(String phone, String serviceName, List<String> billIds) async {
    await _executeRequest(() => client.post(
          Uri.parse('$baseUrl/api/wallets/pay-factures'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'phoneNumber': phone,
            'serviceName': serviceName,
            'factureReferences': billIds,
          }),
        ));
  }
}
