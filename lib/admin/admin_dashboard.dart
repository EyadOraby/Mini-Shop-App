import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_shop/admin/sample_orders.dart';
import 'package:mini_shop/cubits/orders_cubit.dart';
import 'package:mini_shop/cubits/product_cubit.dart';
import 'package:mini_shop/logic/cart_summary.dart';
import 'package:mini_shop/logic/store_stats.dart';
import 'package:mini_shop/models/order_model.dart';
import 'package:mini_shop/models/product_model.dart';
import 'package:mini_shop/widgets/common.dart';

enum AdminSection { overview, products, orders }

/// The store owner's view: sales figures, the catalog and every order.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, this.initial = AdminSection.overview, this.clock = DateTime.now});

  final AdminSection initial;
  final DateTime Function() clock;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late var _section = widget.initial;

  static const _items = [
    (Icons.space_dashboard_outlined, Icons.space_dashboard_rounded, 'Overview'),
    (Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Products'),
    (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Orders'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final orders = context.watch<OrdersCubit>().state;
    final products = context.watch<ProductCubit>().state.products;
    final now = widget.clock();
    final stats = StoreStats(orders: orders, products: products);

    final body = switch (_section) {
      AdminSection.overview => _Overview(stats: stats, now: now),
      AdminSection.products => _ProductsTable(products: products, sold: stats.unitsByProduct),
      AdminSection.orders => _OrdersTable(orders: orders, now: now),
    };

    final content = Scaffold(
      appBar: AppBar(
        title: Text(_items[_section.index].$3),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Data',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) {
              final cubit = context.read<OrdersCubit>();
              if (v == 'seed') cubit.addAll(sampleOrders(products, now, seed: orders.length + 7));
              if (v == 'clear') cubit.clear();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'seed', child: Text('Add sample orders')),
              PopupMenuItem(value: 'clear', child: Text('Clear all orders')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: orders.isEmpty && _section != AdminSection.products
          ? EmptyState(
              icon: Icons.insights_rounded,
              title: 'No sales yet',
              message: 'Place an order in the shop, or fill the dashboard with sample orders.',
              action: FilledButton.icon(
                onPressed: products.isEmpty
                    ? null
                    : () => context.read<OrdersCubit>().addAll(sampleOrders(products, now)),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Add sample orders'),
              ),
            )
          : body,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _section.index,
              onDestinationSelected: (i) => setState(() => _section = AdminSection.values[i]),
              destinations: [
                for (final i in _items) NavigationDestination(icon: Icon(i.$1), selectedIcon: Icon(i.$2), label: i.$3),
              ],
            ),
    );

    if (!wide) return content;
    return Row(
      children: [
        NavigationRail(
          extended: MediaQuery.sizeOf(context).width >= 1200,
          selectedIndex: _section.index,
          onDestinationSelected: (i) => setState(() => _section = AdminSection.values[i]),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (Navigator.canPop(context)) const BackButton(),
                Icon(Icons.storefront_rounded, color: Theme.of(context).colorScheme.primary, size: 30),
              ],
            ),
          ),
          destinations: [
            for (final i in _items)
              NavigationRailDestination(icon: Icon(i.$1), selectedIcon: Icon(i.$2), label: Text(i.$3)),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: content),
      ],
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.stats, required this.now});

  final StoreStats stats;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final kpiColumns = width >= 1100 ? 4 : 2;
    final kpis = [
      _Kpi(Icons.payments_rounded, 'Revenue', money(stats.revenue)),
      _Kpi(Icons.shopping_cart_checkout_rounded, 'Orders', '${stats.orders.length}'),
      _Kpi(Icons.trending_up_rounded, 'Average order', money(stats.averageOrder)),
      _Kpi(Icons.inventory_rounded, 'Units sold', '${stats.unitsSold}'),
    ];
    final charts = [
      _Panel(title: 'Revenue, last 7 days', child: _BarChart(values: stats.dailyRevenue(now), now: now)),
      _Panel(title: 'Sales by category', child: _CategoryBars(entries: stats.revenueByCategory)),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: kpiColumns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: width >= 1100 ? 2.0 : (width >= 600 ? 2.6 : 1.4),
          children: kpis,
        ),
        const SizedBox(height: 12),
        if (width >= 1000)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [Expanded(flex: 3, child: charts[0]), const SizedBox(width: 12), Expanded(flex: 2, child: charts[1])],
            ),
          )
        else ...[charts[0], const SizedBox(height: 12), charts[1]],
        const SizedBox(height: 12),
        _Panel(
          title: 'Order status',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final e in stats.statusCounts(now).entries) _StatusPill(status: e.key, count: e.value),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'Recent orders',
          child: Column(
            children: [for (final o in stats.orders.take(5)) _OrderRow(order: o, now: now)],
          ),
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                ),
                Text(label, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.values, required this.now});

  final List<double> values;
  final DateTime now;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final top = values.fold(0.0, (a, b) => a > b ? a : b);
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, v) in values.indexed)
            Expanded(
              child: Tooltip(
                message: money(v),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        height: top == 0 ? 4 : 4 + 156 * v / top,
                        decoration: BoxDecoration(
                          color: i == values.length - 1 ? scheme.primary : scheme.primary.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _days[now.subtract(Duration(days: values.length - 1 - i)).weekday - 1],
                        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryBars extends StatelessWidget {
  const _CategoryBars({required this.entries});

  final List<MapEntry<String, double>> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = entries.fold(0.0, (s, e) => s + e.value);
    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(titleCase(e.key), style: const TextStyle(fontWeight: FontWeight.w600))),
                    Text(money(e.value), style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : e.value / total,
                    minHeight: 8,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

Color _statusColor(String status) => switch (status) {
      'Delivered' => const Color(0xFF2E9D5B),
      'Shipped' => const Color(0xFF3B7DD8),
      _ => const Color(0xFFE09A1F),
    };

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, this.count});

  final String status;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: count == null ? 4 : 10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        count == null ? status : '$status · $count',
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.now});

  final Order order;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => _showOrder(context, order, now),
      leading: CircleAvatar(child: Text(order.name.isEmpty ? '?' : order.name[0])),
      title: Text(order.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${order.id} · ${order.itemCount} items'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(money(order.total), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          _StatusPill(status: order.statusAt(now)),
        ],
      ),
    );
  }
}

String _date(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void _showOrder(BuildContext context, Order order, DateTime now) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(order.id),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.name} · ${order.address}'),
            Text('${_date(order.placedAt)} · ${order.payment}'),
            const SizedBox(height: 8),
            _StatusPill(status: order.statusAt(now)),
            const Divider(height: 24),
            for (final l in order.lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text('${l.quantity} × ${l.name}', maxLines: 2, overflow: TextOverflow.ellipsis)),
                    Text(money(l.price * l.quantity)),
                  ],
                ),
              ),
            const Divider(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Total ${money(order.total)}', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ),
  );
}

class _ProductsTable extends StatefulWidget {
  const _ProductsTable({required this.products, required this.sold});

  final List<Product> products;
  final Map<int, int> sold;

  @override
  State<_ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<_ProductsTable> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final rows = widget.products
        .where((p) => p.title.toLowerCase().contains(q) || p.category.toLowerCase().contains(q))
        .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(hintText: 'Search products or categories', prefixIcon: Icon(Icons.search_rounded)),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Price'), numeric: true),
                DataColumn(label: Text('Rating'), numeric: true),
                DataColumn(label: Text('Sold'), numeric: true),
              ],
              rows: [
                for (final p in rows)
                  DataRow(cells: [
                    DataCell(Row(
                      children: [
                        SizedBox(width: 36, height: 36, child: ProductImage(url: p.image, padding: 4, radius: 8)),
                        const SizedBox(width: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    )),
                    DataCell(Text(titleCase(p.category))),
                    DataCell(Text(money(p.price))),
                    DataCell(Text('${p.rating.toStringAsFixed(1)} (${p.ratingCount})')),
                    DataCell(Text('${widget.sold[p.id] ?? 0}')),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrdersTable extends StatelessWidget {
  const _OrdersTable({required this.orders, required this.now});

  final List<Order> orders;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: false,
              columns: const [
                DataColumn(label: Text('Order')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Items'), numeric: true),
                DataColumn(label: Text('Total'), numeric: true),
                DataColumn(label: Text('Status')),
              ],
              rows: [
                for (final o in orders)
                  DataRow(
                    onSelectChanged: (_) => _showOrder(context, o, now),
                    cells: [
                      DataCell(Text(o.id, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(o.name)),
                      DataCell(Text(_date(o.placedAt))),
                      DataCell(Text('${o.itemCount}')),
                      DataCell(Text(money(o.total))),
                      DataCell(_StatusPill(status: o.statusAt(now))),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
