class Transaction {
  final String id;
  final String fromPhone;
  final String toPhone;
  final double amount;
  final String type;
  final DateTime date;

  Transaction({
    required this.id,
    required this.fromPhone,
    required this.toPhone,
    required this.amount,
    required this.type,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      fromPhone: json['fromPhone'] as String,
      toPhone: json['toPhone'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromPhone': fromPhone,
      'toPhone': toPhone,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };
  }
}
