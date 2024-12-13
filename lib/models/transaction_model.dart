class TransactionItem {
  final int? id;
  final int itemId;
  final String type; // 'in' atau 'out'
  final int quantity;
  final String date;

  TransactionItem({
    this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'type': type,
    'quantity': quantity,
    'date': date,
  };

  static TransactionItem fromJson(Map<String, dynamic> json) => TransactionItem(
    id: json['id'],
    itemId: json['itemId'],
    type: json['type'],
    quantity: json['quantity'],
    date: json['date'],
  );
}