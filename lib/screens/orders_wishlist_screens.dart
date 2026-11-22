import 'package:material_ui/material_ui.dart';
import 'package:makers_market/app/theme.dart';
import 'package:makers_market/app/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makers_market/cubits/orders_cubit.dart';
import 'package:makers_market/cubits/product_cubit.dart';
import 'package:makers_market/cubits/wishlist_cubit.dart';
import 'package:makers_market/logic/cart_summary.dart';
import 'package:makers_market/models/order_model.dart';
import 'package:makers_market/widgets/common.dart';
import 'package:makers_market/widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ids = context.watch<WishlistCubit>().state;
    final products = context.watch<ProductCubit>().state.products.where((p) => ids.contains(p.id)).toList();
    final columns = (MediaQuery.sizeOf(context).width / 210).floor().clamp(2, 6);
    return Scaffold(
      appBar: AppBar(title: Text(context.t('Wishlist'))),
      body: products.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: context.t('Nothing saved yet'),
              message: context.t('Tap the heart on any product to keep it here.'),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 300,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => ProductCard(product: products[i]),
            ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('Orders'))),
      body: orders.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: context.t('No orders yet'),
              message: context.t('Orders you place will show up here with their status.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OrderCard(order: orders[i]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final status = order.statusAt(DateTime.now());
    final scheme = Theme.of(context).colorScheme;
    final steps = [context.t('Processing'), context.t('Shipped'), context.t('Delivered')];
    final reached = steps.indexOf(status);
    final d = order.placedAt;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(order.id, style: const TextStyle(fontFamily: display, fontFamilyFallback: displayFallback, fontWeight: FontWeight.w600, fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                  child: Text(context.t(status),
                      style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${d.day}/${d.month}/${d.year} · ${order.itemCount} ${context.t('items')} · ${order.payment}',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: order.lines.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) =>
                    SizedBox(width: 56, child: ProductImage(url: order.lines[i].imageUrl, padding: 6, radius: 12)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  Icon(i <= reached ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                      size: 18, color: i <= reached ? scheme.primary : scheme.outline),
                  const SizedBox(width: 4),
                  Text(context.t(steps[i]), style: TextStyle(fontSize: 12, fontWeight: i <= reached ? FontWeight.w700 : FontWeight.w400)),
                  if (i < steps.length - 1)
                    Expanded(child: Divider(indent: 6, endIndent: 6, color: i < reached ? scheme.primary : scheme.outlineVariant)),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text('${context.t('Total')} ${money(order.total)}', style: const TextStyle(fontFamily: display, fontFamilyFallback: displayFallback, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
