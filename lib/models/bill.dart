class Bill {
  final String id;
  final String provider;
  final double amount;
  final bool isPaid;

  Bill({
    required this.id,
    required this.provider,
    required this.amount,
    required this.isPaid,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      provider: json['provider'] as String,
      amount: (json['amount'] as num).toDouble(),
      isPaid: json['isPaid'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'amount': amount,
      'isPaid': isPaid,
    };
  }
}
