import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_shop/core/storage.dart';
import 'package:mini_shop/logic/cart_summary.dart';
import 'package:mini_shop/models/cart_item_model.dart';
import 'package:mini_shop/models/order_model.dart';

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
