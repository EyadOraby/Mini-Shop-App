import 'package:mini_shop/models/cart_item_model.dart';

/// Promo codes the shop accepts, as a fraction off the subtotal.
const promoCodes = {'MINI10': 0.10, 'WELCOME20': 0.20};

/// Orders at or above this subtotal ship for free.
const freeShippingFrom = 100.0;
const shippingFee = 5.0;

/// Everything the cart and checkout show, computed in one place.
class CartSummary {
  final int itemCount;
  final double subtotal;
  final double discount;
  final double shipping;
  final String? promoCode;

  const CartSummary({
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    this.promoCode,
  });

  double get total => subtotal - discount + shipping;

  /// How much more to spend for free shipping, or 0.
  double get toFreeShipping => subtotal >= freeShippingFrom ? 0 : freeShippingFrom - subtotal;

  factory CartSummary.of(List<CartItem> items, {String? promoCode}) {
    final subtotal = items.fold<double>(0, (sum, i) => sum + i.price * i.quantity);
    final count = items.fold<int>(0, (sum, i) => sum + i.quantity);
    final code = promoCode?.trim().toUpperCase();
    final rate = promoCodes[code] ?? 0;
    return CartSummary(
      itemCount: count,
      subtotal: _round(subtotal),
      discount: _round(subtotal * rate),
      shipping: items.isEmpty || subtotal >= freeShippingFrom ? 0 : shippingFee,
      promoCode: rate > 0 ? code : null,
    );
  }

  static double _round(double v) => (v * 100).roundToDouble() / 100;
}

String money(double v) => '\$${v.toStringAsFixed(2)}';
