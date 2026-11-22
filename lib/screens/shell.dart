import 'package:material_ui/material_ui.dart';
import 'package:makers_market/app/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makers_market/cubits/cart_cubit.dart';
import 'package:makers_market/cubits/wishlist_cubit.dart';
import 'package:makers_market/screens/cart_screen.dart';
import 'package:makers_market/screens/orders_wishlist_screens.dart';
import 'package:makers_market/screens/shop_screen.dart';

enum ShopTab { shop, wishlist, cart, orders }

/// Bottom navigation between the shop, wishlist, cart and orders.
class Shell extends StatefulWidget {
  const Shell({super.key, this.initial = ShopTab.shop});

  final ShopTab initial;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late int _index = widget.initial.index;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<CartCubit, int>((c) => c.state.summary.itemCount);
    final saved = context.select<WishlistCubit, int>((c) => c.state.length);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const ShopScreen(),
          const WishlistScreen(),
          CartScreen(onShop: () => setState(() => _index = 0)),
          const OrdersScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront_rounded),
            label: context.t('Shop'),
          ),
          NavigationDestination(
            icon: Badge(isLabelVisible: saved > 0, label: Text('$saved'), child: const Icon(Icons.favorite_border_rounded)),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: context.t('Wishlist'),
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: const Icon(Icons.shopping_bag_rounded),
            label: context.t('Cart'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: context.t('Orders'),
          ),
        ],
      ),
    );
  }
}
