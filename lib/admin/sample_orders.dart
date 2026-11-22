import 'dart:math';

import 'package:makers_market/models/order_model.dart';
import 'package:makers_market/models/product_model.dart';

const _names = ['Mona Adel', 'Omar Fathy', 'Sara Nabil', 'Youssef Hany', 'Laila Samir', 'Karim Ezz', 'Nour Tarek'];
const _cities = ['Cairo', 'Giza', 'Alexandria', 'Mansoura', 'Tanta'];

/// A fortnight of believable orders, so the dashboard has something to show.
List<Order> sampleOrders(List<Product> products, DateTime now, {int count = 24, int seed = 7}) {
  if (products.isEmpty) return const [];
  final rnd = Random(seed);
  return List.generate(count, (i) {
    final placedAt = now.subtract(Duration(hours: rnd.nextInt(14 * 24), minutes: rnd.nextInt(60)));
    final lines = <OrderLine>[];
    final picks = <int>{};
    for (final n = min(1 + rnd.nextInt(3), products.length); picks.length < n;) {
      picks.add(rnd.nextInt(products.length));
    }
    for (final idx in picks) {
      final p = products[idx];
      lines.add(OrderLine(productId: p.id, name: p.title, imageUrl: p.image, price: p.price, quantity: 1 + rnd.nextInt(2)));
    }
    return Order(
      id: 'MS-S${(1000 + i).toString()}',
      placedAt: placedAt,
      lines: lines,
      total: lines.fold(0.0, (s, l) => s + l.price * l.quantity),
      name: _names[rnd.nextInt(_names.length)],
      address: _cities[rnd.nextInt(_cities.length)],
      payment: rnd.nextBool() ? 'Card' : 'Cash on delivery',
    );
  });
}
