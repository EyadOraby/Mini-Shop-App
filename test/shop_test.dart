import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makers_market/core/storage.dart';
import 'package:makers_market/cubits/cart_cubit.dart';
import 'package:makers_market/cubits/orders_cubit.dart';
import 'package:makers_market/cubits/wishlist_cubit.dart';
import 'package:makers_market/logic/cart_summary.dart';
import 'package:makers_market/models/cart_item_model.dart';
import 'package:makers_market/models/order_model.dart';
import 'package:makers_market/models/product_model.dart';
import 'package:makers_market/repositories/product_repository.dart';
import 'package:makers_market/screens/checkout_screen.dart';
import 'package:makers_market/services/api_service.dart';

const shirt = Product(id: 1, title: 'Bowl', price: 400, description: '', category: 'pottery', image: '');
const ring = Product(id: 2, title: 'Lantern', price: 1800, description: '', category: 'lighting', image: '');

CartItem line(Product p, int q) =>
    CartItem(productId: p.id, quantity: q, name: p.title, price: p.price, imageUrl: p.image);

void main() {
  group('CartSummary', () {
    test('charges shipping under the threshold and drops it above', () {
      final small = CartSummary.of([line(shirt, 2)]);
      expect(small.subtotal, 800);
      expect(small.shipping, shippingFee);
      expect(small.total, 880);
      expect(small.toFreeShipping, 1200);

      final big = CartSummary.of([line(shirt, 1), line(ring, 1)]);
      expect(big.shipping, 0);
      expect(big.total, 2200);
    });

    test('applies valid promo codes, ignoring case and spaces', () {
      final s = CartSummary.of([line(ring, 1)], promoCode: ' makers10 ');
      expect(s.promoCode, 'MAKERS10');
      expect(s.discount, 180);
      expect(s.total, 1800 - 180 + shippingFee);
      expect(CartSummary.of([line(ring, 1)], promoCode: 'NOPE').discount, 0);
    });

    test('an empty cart costs nothing', () {
      expect(CartSummary.of([]).total, 0);
    });
  });

  group('CartCubit', () {
    test('adds, merges, changes and removes lines, and saves them', () {
      final store = MemoryStore();
      final cart = CartCubit(store)
        ..add(shirt)
        ..add(shirt, quantity: 2)
        ..add(ring);
      expect(cart.state.quantityOf(shirt.id), 3);
      expect(cart.state.summary.itemCount, 4);

      cart.setQuantity(ring.id, 0);
      expect(cart.state.items.map((i) => i.productId), [shirt.id]);

      expect(CartCubit(store).state.quantityOf(shirt.id), 3, reason: 'restored from storage');
    });

    test('undo puts a removed line back', () {
      final cart = CartCubit(MemoryStore())..add(ring);
      final removed = cart.remove(ring.id)!;
      expect(cart.state.items, isEmpty);
      cart.restore(removed);
      expect(cart.state.quantityOf(ring.id), 1);
    });

    test('only accepts known promo codes', () {
      final cart = CartCubit(MemoryStore())..add(ring);
      expect(cart.applyPromo('FREE100'), isFalse);
      expect(cart.applyPromo('welcome20'), isTrue);
      expect(cart.state.summary.discount, 360);
    });
  });

  test('wishlist toggles and persists', () {
    final store = MemoryStore();
    final wishlist = WishlistCubit(store)..toggle(1)..toggle(2)..toggle(1);
    expect(wishlist.state, {2});
    expect(WishlistCubit(store).state, {2});
  });

  group('orders', () {
    test('placing an order snapshots the cart and survives a restart', () {
      final store = MemoryStore();
      final placedAt = DateTime(2026, 1, 1, 10);
      final orders = OrdersCubit(store, clock: () => placedAt);
      final items = [line(shirt, 2)];
      final order = orders.place(
        items: items,
        summary: CartSummary.of(items),
        name: 'Eyad',
        address: 'Giza',
        payment: 'Card',
      );
      expect(order.total, 880);
      expect(order.itemCount, 2);
      final restored = OrdersCubit(store).state.single;
      expect(restored.id, order.id);
      expect(restored.lines.single.name, 'Bowl');
    });

    test('status moves from processing to shipped to delivered', () {
      final o = Order(
        id: 'x',
        placedAt: DateTime(2026, 1, 1),
        lines: const [],
        total: 0,
        name: '',
        address: '',
        payment: '',
      );
      expect(o.statusAt(DateTime(2026, 1, 1, 5)), 'Processing');
      expect(o.statusAt(DateTime(2026, 1, 2, 1)), 'Shipped');
      expect(o.statusAt(DateTime(2026, 1, 5)), 'Delivered');
    });
  });

  test('language toggles, is remembered, and ?lang= wins', () {
    final store = MemoryStore();
    LocaleCubit(store).toggle();
    expect(LocaleCubit(store).state.languageCode, 'ar');
    expect(LocaleCubit(store, override: 'en').state.languageCode, 'en');
  });

  test('theme toggles and is remembered', () {
    final store = MemoryStore();
    ThemeCubit(store).toggle();
    expect(ThemeCubit(store).state, ThemeMode.dark);
  });

  test('checkout validates phone numbers', () {
    expect(validatePhone(''), isNotNull);
    expect(validatePhone('12'), isNotNull);
    expect(validatePhone('+20 100 123 4567'), isNull);
  });

  group('catalog fallback', () {
    const json = '[{"id":7,"title":"Lamp","price":12,"description":"","category":"home","image":"","rating":{"rate":4.5,"count":3}}]';

    test('uses the copy bundled with the app when offline and nothing is cached', () async {
      final repo = ProductRepository(apiService: _OfflineApi(), store: MemoryStore(), loadBundled: () async => json);
      final products = await repo.getAllProducts();
      expect(products.single.title, 'Lamp');
      expect(products.single.rating, 4.5);
    });

    test('prefers the last good copy saved on the device', () async {
      final store = MemoryStore()..data['catalog'] = json.replaceAll('Lamp', 'Cached lamp');
      final repo = ProductRepository(apiService: _OfflineApi(), store: store, loadBundled: () async => json);
      expect((await repo.getAllProducts()).single.title, 'Cached lamp');
    });
  });
}

class _OfflineApi extends ApiService {
  @override
  Future<Never> fetchAllProducts() async => throw Exception('offline');
}
