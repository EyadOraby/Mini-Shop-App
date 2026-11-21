class CartItem {
  final int productId;
  final int quantity;
  final String name;
  final double price;
  final String imageUrl;

  const CartItem({
    required this.productId,
    required this.quantity,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        quantity: quantity ?? this.quantity,
        name: name,
        price: price,
        imageUrl: imageUrl,
      );

  Map<String, dynamic> toJson() =>
      {'productId': productId, 'quantity': quantity, 'name': name, 'price': price, 'imageUrl': imageUrl};

  factory CartItem.fromJson(Map json) => CartItem(
        productId: json['productId'] as int,
        quantity: json['quantity'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
      );
}
