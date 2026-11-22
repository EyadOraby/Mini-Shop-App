import 'package:material_ui/material_ui.dart';
import 'package:makers_market/widgets/craft_art.dart';
import 'package:makers_market/app/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makers_market/admin/admin_dashboard.dart';
import 'package:makers_market/app/theme.dart';
import 'package:makers_market/cubits/orders_cubit.dart';
import 'package:makers_market/cubits/product_cubit.dart';
import 'package:makers_market/widgets/common.dart';
import 'package:makers_market/widgets/product_card.dart';

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
                title: Text(context.t("Maker's Market")),
                actions: [
                  IconButton(
                    tooltip: context.t('Language'),
                    onPressed: () => context.read<LocaleCubit>().toggle(),
                    icon: const Icon(Icons.translate_rounded),
                  ),
                  IconButton(
                    tooltip: context.t('Store dashboard'),
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => const AdminDashboard())),
                    icon: const Icon(Icons.space_dashboard_outlined),
                  ),
                  IconButton(
                    tooltip: context.t('Toggle dark mode'),
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
                      Text(context.t('Every piece is made by hand, so each one is a little different.'),
                          style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: cubit.filterProducts,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: context.t('Search products'),
                                prefixIcon: const Icon(Icons.search_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<ProductSort>(
                            tooltip: context.t('Sort'),
                            initialValue: state.sort,
                            onSelected: cubit.sortBy,
                            itemBuilder: (_) => [
                              for (final e in _sortLabels.entries) PopupMenuItem(value: e.key, child: Text(context.t(e.value))),
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
                          label: context.t('All'),
                          icon: Icons.apps_rounded,
                          selected: state.category == null,
                          onTap: () => cubit.selectCategory(null),
                        ),
                        for (final c in state.categories)
                          _CategoryChip(
                            label: context.t(titleCase(c)),
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
                      Text(state.category == null ? context.t('Popular now') : context.t(titleCase(state.category!)),
                          style: const TextStyle(fontSize: 18, fontFamily: display, fontFamilyFallback: displayFallback, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('${products.length} ${context.t('items')}', style: TextStyle(color: scheme.onSurfaceVariant)),
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
                    title: context.t('You seem to be offline'),
                    message: state.errorMessage!,
                    action: FilledButton.icon(
                      onPressed: cubit.fetchProducts,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(context.t('Try again')),
                    ),
                  ),
                )
              else if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: context.t('No matches'),
                    message: context.t('Try another search or category.'),
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

  static const _pieces = [
    CraftArtSpec('vase', Color(0xFFB5532C), Color(0xFFF3EADB), 'waves'),
    CraftArtSpec('basket', Color(0xFFD9A441), Color(0xFFC9786A), 'zigzag'),
    CraftArtSpec('lantern', Color(0xFF2F6F6A), Color(0xFFD9A441), 'dots'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: ColoredBox(
        color: indigo,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.t('Handmade in Egypt').toUpperCase(),
                            style: const TextStyle(color: saffron, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                        const SizedBox(height: 6),
                        Text(context.t('Meet the makers'),
                            style: const TextStyle(fontFamily: display, fontFamilyFallback: displayFallback, color: sand, fontSize: 24, fontWeight: FontWeight.w600, height: 1.1)),
                        const SizedBox(height: 6),
                        Text(context.t('Pieces from workshops in Fayoum, Aswan, Siwa and Cairo. 20% off your first order with WELCOME20.'),
                            style: TextStyle(color: sand.withValues(alpha: .78), fontSize: 12.5, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 112,
                    height: 72,
                    child: Stack(
                      children: [
                        for (var k = 0; k < _pieces.length; k++)
                          Positioned(left: k * 32.0, bottom: 0, width: 56, height: 56, child: CraftArt(spec: _pieces[k], niche: false)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // A Nubian zigzag border along the bottom.
            SizedBox(height: 10, width: double.infinity, child: CustomPaint(painter: _ZigzagBorder())),
          ],
        ),
      ),
    );
  }
}

class _ZigzagBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height);
    var x = 0.0;
    var up = true;
    while (x <= size.width + 10) {
      path.lineTo(x, up ? 0 : size.height);
      x += 10;
      up = !up;
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = clay);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        labelStyle: TextStyle(
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: selected ? scheme.onPrimary : scheme.onSurface,
        ),
        selectedColor: scheme.primary,
        backgroundColor: Theme.of(context).cardTheme.color,
      ),
    );
  }
}
