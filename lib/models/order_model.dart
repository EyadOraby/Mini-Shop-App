/// A placed order, stored as plain JSON so it needs no Hive adapter.
class OrderLine {
  final int productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;

  const OrderLine({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() =>
      {'productId': productId, 'name': name, 'imageUrl': imageUrl, 'price': price, 'quantity': quantity};

  factory OrderLine.fromJson(Map json) => OrderLine(
        productId: json['productId'] as int,
        name: json['name'] as String,
        imageUrl: json['imageUrl'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
      );
}

class Order {
  final String id;
  final DateTime placedAt;
  final List<OrderLine> lines;
  final double total;
  final String name;
  final String address;
  final String payment;

  const Order({
    required this.id,
    required this.placedAt,
    required this.lines,
    required this.total,
    required this.name,
    required this.address,
    required this.payment,
  });

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  /// A simple delivery timeline: processing for a day, then shipped, then delivered.
  String statusAt(DateTime now) {
    final age = now.difference(placedAt);
    if (age.inDays >= 3) return 'Delivered';
    if (age.inDays >= 1) return 'Shipped';
    return 'Processing';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'placedAt': placedAt.toIso8601String(),
        'lines': lines.map((l) => l.toJson()).toList(),
        'total': total,
        'name': name,
        'address': address,
        'payment': payment,
      };

  factory Order.fromJson(Map json) => Order(
        id: json['id'] as String,
        placedAt: DateTime.parse(json['placedAt'] as String),
        lines: (json['lines'] as List).map((l) => OrderLine.fromJson(l as Map)).toList(),
        total: (json['total'] as num).toDouble(),
        name: json['name'] as String,
        address: json['address'] as String,
        payment: json['payment'] as String,
      );
}
