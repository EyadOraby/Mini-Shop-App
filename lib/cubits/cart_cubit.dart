import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_shop/core/storage.dart';
import 'package:mini_shop/logic/cart_summary.dart';
import 'package:mini_shop/models/cart_item_model.dart';
import 'package:mini_shop/models/product_model.dart';

class CartState {
  final List<CartItem> items;
  final String? promoCode;

  const CartState({this.items = const [], this.promoCode});

  CartSummary get summary => CartSummary.of(items, promoCode: promoCode);

  int quantityOf(int productId) =>
      items.where((i) => i.productId == productId).fold(0, (sum, i) => sum + i.quantity);
}

/// The cart, saved to the device after every change.
class CartCubit extends Cubit<CartState> {
  CartCubit(this._store) : super(const CartState()) {
    final saved = _store.read(_key);
    if (saved is List) {
      emit(CartState(items: saved.map((e) => CartItem.fromJson(e as Map)).toList()));
    }
  }

  static const _key = 'cart';
  final KeyValueStore _store;

  void _save(List<CartItem> items, {String? promoCode}) {
    emit(CartState(items: items, promoCode: promoCode));
    _store.write(_key, items.map((i) => i.toJson()).toList());
  }

  void add(Product product, {int quantity = 1}) {
    final items = [...state.items];
    final index = items.indexWhere((i) => i.productId == product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + quantity);
    } else {
      items.add(CartItem(
        productId: product.id,
        quantity: quantity,
        name: product.title,
        price: product.price,
        imageUrl: product.image,
      ));
    }
    _save(items, promoCode: state.promoCode);
  }

  /// Sets a quantity; zero or less removes the line.
  void setQuantity(int productId, int quantity) {
    final items = [
      for (final i in state.items)
        if (i.productId != productId) i else if (quantity > 0) i.copyWith(quantity: quantity),
    ];
    _save(items, promoCode: items.isEmpty ? null : state.promoCode);
  }

  /// Removes a line and returns it, so the UI can offer undo.
  CartItem? remove(int productId) {
    final index = state.items.indexWhere((i) => i.productId == productId);
    if (index < 0) return null;
    final removed = state.items[index];
    setQuantity(productId, 0);
    return removed;
  }

  void restore(CartItem item) {
    if (state.items.any((i) => i.productId == item.productId)) return;
    _save([...state.items, item], promoCode: state.promoCode);
  }

  /// Applies a promo code; returns false if it isn't valid.
  bool applyPromo(String code) {
    final valid = promoCodes.containsKey(code.trim().toUpperCase());
    if (valid) _save(state.items, promoCode: code.trim().toUpperCase());
    return valid;
  }

  void clearPromo() => _save(state.items);

  void clear() => _save(const []);
}
