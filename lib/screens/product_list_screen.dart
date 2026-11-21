import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_shop/cubits/product_cubit.dart';
import 'package:mini_shop/screens/product_details_screen.dart';
import 'package:mini_shop/widgets/appBar_widget.dart';
import 'package:mini_shop/widgets/cart_floating_action_button.dart';
import 'package:mini_shop/widgets/loading_indicator.dart';
import 'package:mini_shop/widgets/product_card.dart';

const _sortLabels = {
  ProductSort.featured: 'Featured',
  ProductSort.priceLowHigh: 'Price: low to high',
  ProductSort.priceHighLow: 'Price: high to low',
  ProductSort.name: 'Name',
};

String _titleCase(String value) => value
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductCubit>();
    return Scaffold(
      appBar: const AppBarWidget(title: 'Products'),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: cubit.filterProducts,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search products',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<ProductSort>(
                      tooltip: 'Sort',
                      icon: const Icon(Icons.sort),
                      initialValue: state.sort,
                      onSelected: cubit.sortBy,
                      itemBuilder: (context) => [
                        for (final entry in _sortLabels.entries)
                          PopupMenuItem(value: entry.key, child: Text(entry.value)),
                      ],
                    ),
                  ],
                ),
              ),
              if (state.categories.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _CategoryChip(
                        label: 'All',
                        selected: state.category == null,
                        onTap: () => cubit.selectCategory(null),
                      ),
                      for (final category in state.categories)
                        _CategoryChip(
                          label: _titleCase(category),
                          selected: state.category == category,
                          onTap: () => cubit.selectCategory(category),
                        ),
                    ],
                  ),
                ),
              Expanded(child: _ProductGrid(state: state, onRetry: cubit.fetchProducts)),
            ],
          );
        },
      ),
      floatingActionButton: const CartFloatingActionButton(),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.state, required this.onRetry});

  final ProductState state;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.products.isEmpty) return const LoadingIndicator();

    if (state.errorMessage != null && state.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48),
              const SizedBox(height: 12),
              Text(state.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final products = state.filteredProducts;
    return RefreshIndicator(
      onRefresh: onRetry,
      child: products.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No products match your search.')),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // More columns on tablets and the web.
                final columns = (constraints.maxWidth / 220).floor().clamp(2, 6);
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(productId: product.id),
                        ),
                      ),
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: ProductCard(product: product),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
