import 'package:mini_shop/models/order_model.dart';
import 'package:mini_shop/models/product_model.dart';

/// Figures for the admin dashboard, worked out from the orders and catalog.
class StoreStats {
  StoreStats({required this.orders, required this.products});

  final List<Order> orders;
  final List<Product> products;

  double get revenue => orders.fold(0, (sum, o) => sum + o.total);
  int get unitsSold => orders.fold(0, (sum, o) => sum + o.itemCount);
  double get averageOrder => orders.isEmpty ? 0 : revenue / orders.length;

  /// Units sold per product id.
  Map<int, int> get unitsByProduct {
    final out = <int, int>{};
    for (final o in orders) {
      for (final l in o.lines) {
        out[l.productId] = (out[l.productId] ?? 0) + l.quantity;
      }
    }
    return out;
  }

  /// Revenue per category, largest first. Lines for products no longer in
  /// the catalog count as "other".
  List<MapEntry<String, double>> get revenueByCategory {
    final category = {for (final p in products) p.id: p.category};
    final out = <String, double>{};
    for (final o in orders) {
      for (final l in o.lines) {
        final c = category[l.productId] ?? 'other';
        out[c] = (out[c] ?? 0) + l.price * l.quantity;
      }
    }
    return out.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  /// Revenue for each of the last [days] days, oldest first.
  List<double> dailyRevenue(DateTime now, {int days = 7}) {
    final today = DateTime(now.year, now.month, now.day);
    final out = List<double>.filled(days, 0);
    for (final o in orders) {
      final d = DateTime(o.placedAt.year, o.placedAt.month, o.placedAt.day);
      final ago = today.difference(d).inDays;
      if (ago >= 0 && ago < days) out[days - 1 - ago] += o.total;
    }
    return out;
  }

  /// Order counts by status.
  Map<String, int> statusCounts(DateTime now) {
    final out = {'Processing': 0, 'Shipped': 0, 'Delivered': 0};
    for (final o in orders) {
      final s = o.statusAt(now);
      out[s] = out[s]! + 1;
    }
    return out;
  }
}
