import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_shop/app/theme.dart';
import 'package:mini_shop/cubits/orders_cubit.dart';
import 'package:mini_shop/cubits/product_cubit.dart';
import 'package:mini_shop/widgets/common.dart';
import 'package:mini_shop/widgets/product_card.dart';

const _sortLabels = {
  ProductSort.featured: 'Featured',
  ProductSort.priceLowHigh: 'Price: low to high',
  ProductSort.priceHighLow: 'Price: high to low',
  ProductSort.name: 'Name',
};

/// The storefront: greeting, search, a promo banner, categories and the grid.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductCubit>();
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final products = state.filteredProducts;
        final columns = (MediaQuery.sizeOf(context).width / 210).floor().clamp(2, 6);
        return RefreshIndicator(
          onRefresh: cubit.fetchProducts,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: const Text('Mini Shop'),
                actions: [
                  IconButton(
                    tooltip: 'Toggle dark mode',
                    onPressed: () => context.read<ThemeCubit>().toggle(),
                    icon: Icon(Theme.of(context).brightness == Brightness.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Find something you love',
                          style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: cubit.filterProducts,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                hintText: 'Search products',
                                prefixIcon: Icon(Icons.search_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<ProductSort>(
                            tooltip: 'Sort',
                            initialValue: state.sort,
                            onSelected: cubit.sortBy,
                            itemBuilder: (_) => [
                              for (final e in _sortLabels.entries) PopupMenuItem(value: e.key, child: Text(e.value)),
                            ],
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.tune_rounded, color: scheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _PromoBanner(),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              if (state.categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _CategoryChip(
                          label: 'All',
                          icon: Icons.apps_rounded,
                          selected: state.category == null,
                          onTap: () => cubit.selectCategory(null),
                        ),
                        for (final c in state.categories)
                          _CategoryChip(
                            label: titleCase(c),
                            icon: categoryIcon(c),
                            selected: state.category == c,
                            onTap: () => cubit.selectCategory(c),
                          ),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(state.category == null ? 'Popular now' : titleCase(state.category!),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Text('${products.length} items', style: TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              if (state.isLoading && state.products.isEmpty)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (state.errorMessage != null && state.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.wifi_off_rounded,
                    title: 'You seem to be offline',
                    message: state.errorMessage!,
                    action: FilledButton.icon(
                      onPressed: cubit.fetchProducts,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ),
                )
              else if (products.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No matches',
                    message: 'Try another search or category.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 300,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) => ProductCard(product: products[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [brand, Color(0xFF14B39B)]),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                  child: const Text('New here?',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                const Text('20% off your first order',
                    style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Use code WELCOME20 at checkout. Free shipping over \$100.',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35)),
              ],
            ),
          ),
          const Icon(Icons.local_offer_rounded, color: Colors.white30, size: 64),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        avatar: Icon(icon, size: 18, color: selected ? scheme.onPrimary : scheme.onSurfaceVariant),
        label: Text(label),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? scheme.onPrimary : scheme.onSurface,
        ),
        selectedColor: scheme.primary,
        backgroundColor: Theme.of(context).cardTheme.color,
      ),
    );
  }
}
