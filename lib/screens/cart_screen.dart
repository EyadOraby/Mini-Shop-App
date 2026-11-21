import 'package:flutter/material.dart';
import 'package:mini_shop/app/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_shop/app/theme.dart';
import 'package:mini_shop/cubits/cart_cubit.dart';
import 'package:mini_shop/logic/cart_summary.dart';
import 'package:mini_shop/screens/checkout_screen.dart';
import 'package:mini_shop/widgets/common.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.onShop});

  /// Switches to the shop tab when the cart is empty.
  final VoidCallback? onShop;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final summary = state.summary;
        return Scaffold(
          appBar: AppBar(title: Text(state.items.isEmpty ? context.t('Your cart') : '${context.t('Your cart')} (${summary.itemCount})')),
          body: state.items.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: context.t('Your cart is empty'),
                  message: context.t('Browse the shop and add something you like.'),
                  action: onShop == null
                      ? null
                      : FilledButton.tonal(onPressed: onShop, child: Text(context.t('Start shopping'))),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    if (summary.toFreeShipping > 0) _ShippingProgress(summary: summary),
                    for (final item in state.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey(item.productId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(color: coral, borderRadius: BorderRadius.circular(20)),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            final cubit = context.read<CartCubit>();
                            final removed = cubit.remove(item.productId);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                content: Text('${context.t('Removed')} ${item.name}'),
                                action: removed == null
                                    ? null
                                    : SnackBarAction(label: context.t('Undo'), onPressed: () => cubit.restore(removed)),
                              ));
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  SizedBox(width: 84, height: 84, child: ProductImage(url: item.imageUrl, padding: 8)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25)),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(money(item.price * item.quantity),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    color: Theme.of(context).colorScheme.primary)),
                                            const Spacer(),
                                            QuantityStepper(
                                              compact: true,
                                              min: 0,
                                              value: item.quantity,
                                              onChanged: (q) =>
                                                  context.read<CartCubit>().setQuantity(item.productId, q),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    _PromoField(state: state),
                    const SizedBox(height: 16),
                    SummaryCard(summary: summary),
                  ],
                ),
          bottomNavigationBar: state.items.isEmpty
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(CheckoutScreen.route()),
                      child: Text('${context.t('Checkout')} · ${money(summary.total)}'),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _ShippingProgress extends StatelessWidget {
  const _ShippingProgress({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${context.t('Add')} ${money(summary.toFreeShipping)} ${context.t('more for free shipping')}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(minHeight: 8, value: summary.subtotal / freeShippingFrom),
          ),
        ],
      ),
    );
  }
}

class _PromoField extends StatefulWidget {
  const _PromoField({required this.state});

  final CartState state;

  @override
  State<_PromoField> createState() => _PromoFieldState();
}

class _PromoFieldState extends State<_PromoField> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applied = widget.state.promoCode;
    if (applied != null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.local_offer_rounded, color: brand),
          title: Text('$applied ${context.t('applied')}'),
          trailing: TextButton(onPressed: () => context.read<CartCubit>().clearPromo(), child: Text(context.t('Remove'))),
        ),
      );
    }
    return TextField(
      controller: _controller,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        hintText: context.t('Promo code (try MINI10)'),
        prefixIcon: const Icon(Icons.local_offer_outlined),
        errorText: _error,
        suffixIcon: TextButton(
          onPressed: () {
            final ok = context.read<CartCubit>().applyPromo(_controller.text);
            setState(() => _error = ok ? null : context.t('That code is not valid'));
          },
          child: Text(context.t('Apply')),
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {bool bold = false, Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 17 : 14)),
              const Spacer(),
              Text(value,
                  style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: bold ? 17 : 14, color: color)),
            ],
          ),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row(context.t('Subtotal'), money(summary.subtotal)),
            if (summary.discount > 0) row('${context.t('Discount')} (${summary.promoCode})', '-${money(summary.discount)}', color: brand),
            row(context.t('Shipping'), summary.shipping == 0 ? context.t('Free') : money(summary.shipping)),
            const Divider(height: 20),
            row(context.t('Total'), money(summary.total), bold: true),
          ],
        ),
      ),
    );
  }
}
