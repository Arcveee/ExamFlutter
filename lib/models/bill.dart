class Bill {
  final String reference;
  final double amount;
  final DateTime dueDate;
  final String provider;

  Bill({required this.reference, required this.amount, required this.dueDate, required this.provider});

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      reference: json['reference'] ?? json['id'] ?? '',
      amount: (json['amount'] ?? json['montant'] ?? 0).toDouble(),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.now(),
      provider: json['provider'] ?? '',
    );
  }
}
