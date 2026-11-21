import 'package:flutter/material.dart';
import 'package:mini_shop/app/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_shop/app/theme.dart';
import 'package:mini_shop/cubits/cart_cubit.dart';
import 'package:mini_shop/cubits/wishlist_cubit.dart';
import 'package:mini_shop/logic/cart_summary.dart';
import 'package:mini_shop/models/product_model.dart';
import 'package:mini_shop/screens/product_details_screen.dart';
import 'package:mini_shop/widgets/common.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final saved = context.select<WishlistCubit, bool>((c) => c.state.contains(product.id));
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(ProductDetailsScreen.route(product.id)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(tag: 'product-${product.id}', child: ProductImage(url: product.image)),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _RoundIcon(
                        icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: saved ? coral : Colors.black54,
                        tooltip: saved ? context.t('Remove from wishlist') : context.t('Save to wishlist'),
                        onTap: () => context.read<WishlistCubit>().toggle(product.id),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, height: 1.25),
              ),
              const SizedBox(height: 4),
              RatingStars(rating: product.rating, size: 13),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      money(product.price),
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: scheme.primary),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton.filled(
                      tooltip: context.t('Add to cart'),
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      onPressed: () {
                        context.read<CartCubit>().add(product);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text('${context.t('Added to your cart')}: ${product.title}')));
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.color, required this.tooltip, required this.onTap});

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        iconSize: 19,
        onPressed: onTap,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
          child: Icon(icon, key: ValueKey(icon), color: color),
        ),
      ),
    );
  }
}
