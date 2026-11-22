import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makers_market/core/storage.dart';
import 'package:makers_market/logic/cart_summary.dart';
import 'package:makers_market/models/cart_item_model.dart';
import 'package:makers_market/models/order_model.dart';

/// Past orders, newest first.
class OrdersCubit extends Cubit<List<Order>> {
  OrdersCubit(this._store, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const []) {
    final saved = _store.read(_key);
    if (saved is List) emit(saved.map((e) => Order.fromJson(e as Map)).toList());
  }

  static const _key = 'orders';
  final KeyValueStore _store;
  final DateTime Function() _clock;

  Order place({
    required List<CartItem> items,
    required CartSummary summary,
    required String name,
    required String address,
    required String payment,
  }) {
    final now = _clock();
    final order = Order(
      id: 'MS-${now.millisecondsSinceEpoch.toString().substring(5)}',
      placedAt: now,
      lines: [
        for (final i in items)
          OrderLine(productId: i.productId, name: i.name, imageUrl: i.imageUrl, price: i.price, quantity: i.quantity),
      ],
      total: summary.total,
      name: name,
      address: address,
      payment: payment,
    );
    final next = [order, ...state];
    emit(next);
    _store.write(_key, next.map((o) => o.toJson()).toList());
    return order;
  }

  /// Adds orders that already happened, e.g. sample data for the dashboard.
  void addAll(List<Order> orders) {
    final next = [...orders, ...state]..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    emit(next);
    _store.write(_key, next.map((o) => o.toJson()).toList());
  }

  void clear() {
    emit(const []);
    _store.write(_key, const []);
  }
}

/// Light or dark, remembered between visits.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._store) : super(_store.read('dark') == true ? ThemeMode.dark : ThemeMode.light);

  final KeyValueStore _store;

  void toggle() {
    final dark = state != ThemeMode.dark;
    emit(dark ? ThemeMode.dark : ThemeMode.light);
    _store.write('dark', dark);
  }
}

/// English or Arabic, remembered between visits. `?lang=ar` on the web wins.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._store, {String? override})
      : super(Locale(override == 'ar' || override == 'en' ? override! : (_store.read('lang') as String? ?? 'en')));

  final KeyValueStore _store;

  void toggle() {
    final next = state.languageCode == 'ar' ? 'en' : 'ar';
    emit(Locale(next));
    _store.write('lang', next);
  }
}
