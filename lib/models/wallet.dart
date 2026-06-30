class Wallet {
  final int id;
  final String phone;
  final String ownerName;
  final double balance;
  final String currency;

  Wallet({
    required this.id,
    required this.phone,
    required this.ownerName,
    required this.balance,
    required this.currency,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as int,
      phone: json['phoneNumber'] as String,
      ownerName: json['ownerName'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}
