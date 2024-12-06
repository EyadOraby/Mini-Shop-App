import 'package:hive/hive.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 0)
class CartItem {
  @HiveField(0)
  final int productId;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String imageUrl;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  CartItem copyWith({
    int? productId,
    int? quantity,
    String? name,
    double? price,
    String? imageUrl,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
