import 'package:flutter_test/flutter_test.dart';
import 'package:mini_shop/admin/sample_orders.dart';
import 'package:mini_shop/logic/store_stats.dart';
import 'package:mini_shop/models/order_model.dart';
import 'package:mini_shop/models/product_model.dart';

void main() {
  final now = DateTime(2026, 11, 21, 12);
  const products = [
    Product(id: 1, title: 'Bag', price: 10, description: '', category: 'bags', image: ''),
    Product(id: 2, title: 'Ring', price: 50, description: '', category: 'jewelery', image: ''),
  ];
  Order order(int daysAgo, List<OrderLine> lines) => Order(
        id: 'o$daysAgo',
        placedAt: now.subtract(Duration(days: daysAgo)),
        lines: lines,
        total: lines.fold(0.0, (s, l) => s + l.price * l.quantity),
        name: 'A',
        address: 'B',
        payment: 'Card',
      );
  const bag = OrderLine(productId: 1, name: 'Bag', imageUrl: '', price: 10, quantity: 2);
  const ring = OrderLine(productId: 2, name: 'Ring', imageUrl: '', price: 50, quantity: 1);

  test('totals, categories and daily revenue', () {
    final stats = StoreStats(products: products, orders: [order(0, [bag, ring]), order(4, [bag]), order(20, [ring])]);
    expect(stats.revenue, 140);
    expect(stats.unitsSold, 6);
    expect(stats.averageOrder, closeTo(46.67, 0.01));
    expect(stats.unitsByProduct, {1: 4, 2: 2});
    expect(stats.revenueByCategory.first.key, 'jewelery');
    expect(stats.dailyRevenue(now), [0, 0, 20, 0, 0, 0, 70]);
    expect(stats.statusCounts(now), {'Processing': 1, 'Shipped': 0, 'Delivered': 2});
  });

  test('sample orders are repeatable and add up', () {
    final a = sampleOrders(products, now);
    expect(a, hasLength(24));
    expect(sampleOrders(products, now).first.total, a.first.total);
    for (final o in a) {
      expect(o.total, o.lines.fold(0.0, (s, l) => s + l.price * l.quantity));
      expect(o.placedAt.isBefore(now), isTrue);
    }
  });
}
