class Wallet {
  final String id;
  final String phone;
  final double balance;

  Wallet({
    required this.id,
    required this.phone,
    required this.balance,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      phone: json['phone'] as String,
      balance: (json['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'balance': balance,
    };
  }
}
