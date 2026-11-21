import 'package:flutter/material.dart';
import 'package:mini_shop/app/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_shop/app/theme.dart';
import 'package:mini_shop/cubits/cart_cubit.dart';
import 'package:mini_shop/cubits/product_cubit.dart';
import 'package:mini_shop/cubits/wishlist_cubit.dart';
import 'package:mini_shop/logic/cart_summary.dart';
import 'package:mini_shop/models/product_model.dart';
import 'package:mini_shop/widgets/common.dart';
import 'package:mini_shop/widgets/product_card.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final int productId;

  static Route<void> route(int productId) =>
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: productId));

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductCubit>().state;
    final product = state.products.where((p) => p.id == widget.productId).firstOrNull;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : EmptyState(
                icon: Icons.inventory_2_outlined,
                title: context.t('Product not found'),
                message: context.t('It may have been removed from the catalog.'),
              ),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final saved = context.select<WishlistCubit, bool>((c) => c.state.contains(product.id));
    final related = state.products.where((p) => p.category == product.category && p.id != product.id).take(6).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 360,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            actions: [
              IconButton(
                tooltip: saved ? context.t('Remove from wishlist') : context.t('Save to wishlist'),
                onPressed: () => context.read<WishlistCubit>().toggle(product.id),
                icon: Icon(saved ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: saved ? coral : null),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${product.id}',
                child: ProductImage(url: product.image, padding: 48, radius: 0),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        avatar: Icon(categoryIcon(product.category), size: 16),
                        label: Text(context.t(titleCase(product.category))),
                        visualDensity: VisualDensity.compact,
                      ),
                      RatingStars(rating: product.rating, count: product.ratingCount, size: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(product.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.25)),
                  const SizedBox(height: 10),
                  Text(money(product.price),
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: scheme.primary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Perk(icon: Icons.local_shipping_outlined, text: context.t('Free over \$100')),
                      SizedBox(width: 10),
                      _Perk(icon: Icons.replay_rounded, text: context.t('30-day returns')),
                      SizedBox(width: 10),
                      _Perk(icon: Icons.verified_user_outlined, text: context.t('Secure checkout')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(context.t('About this item'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      product.description,
                      maxLines: _expanded ? null : 4,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                      style: TextStyle(height: 1.55, color: scheme.onSurfaceVariant),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(_expanded ? context.t('Show less') : context.t('Read more')),
                  ),
                  if (related.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(context.t('You may also like'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 290,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: related.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => SizedBox(width: 180, child: ProductCard(product: related[i])),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BuyBar(product: product, quantity: _quantity, onQuantity: (q) => setState(() => _quantity = q)),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(height: 4),
            Text(context.t(text), textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.product, required this.quantity, required this.onQuantity});

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantity;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, -4))],
        ),
        child: Row(
          children: [
            QuantityStepper(value: quantity, onChanged: onQuantity),
            const SizedBox(width: 14),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  context.read<CartCubit>().add(product, quantity: quantity);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text('${context.t('Added to your cart')}: $quantity')));
                },
                child: Text('${context.t('Add to cart')} · ${money(product.price * quantity)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
