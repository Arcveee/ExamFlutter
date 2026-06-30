class Transaction {
  final int id;
  final String type;
  final double amount;
  final double fee;
  final String status;
  final int sourceWalletId;
  final int? targetWalletId;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.fee,
    required this.status,
    required this.sourceWalletId,
    required this.targetWalletId,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      status: json['status'] as String,
      sourceWalletId: json['sourceWalletId'] as int,
      targetWalletId: json['targetWalletId'] as int?,
      date: DateTime.parse(json['createdAt'] as String),
    );
  }
}
