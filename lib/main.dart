import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:makers_market/admin/admin_dashboard.dart';
import 'package:makers_market/admin/sample_orders.dart';
import 'package:makers_market/app/theme.dart';
import 'package:makers_market/core/storage.dart';
import 'package:makers_market/cubits/cart_cubit.dart';
import 'package:makers_market/cubits/orders_cubit.dart';
import 'package:makers_market/cubits/product_cubit.dart';
import 'package:makers_market/cubits/wishlist_cubit.dart';
import 'package:makers_market/repositories/product_repository.dart';
import 'package:makers_market/screens/checkout_screen.dart';
import 'package:makers_market/screens/product_details_screen.dart';
import 'package:makers_market/screens/shell.dart';
import 'package:makers_market/services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final store = await HiveStore.open('makers_market');
  runApp(MakersMarketApp(store: store));
}

class MakersMarketApp extends StatelessWidget {
  const MakersMarketApp({super.key, required this.store, this.url});

  final KeyValueStore store;

  /// Overrides the page URL in tests.
  final Uri? url;

  @override
  Widget build(BuildContext context) {
    final link = url ?? (kIsWeb ? Uri.base : null);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductCubit(
              repository:
                  ProductRepository(apiService: ApiService(), store: store))
            ..fetchProducts(),
        ),
        BlocProvider(create: (_) => CartCubit(store)),
        BlocProvider(create: (_) => WishlistCubit(store)),
        BlocProvider(create: (_) => OrdersCubit(store)),
        BlocProvider(create: (_) => ThemeCubit(store)),
        BlocProvider(
            create: (_) =>
                LocaleCubit(store, override: link?.queryParameters['lang'])),
      ],
      child: Builder(
        builder: (context) {
          final mode = context.watch<ThemeCubit>().state;
          final locale = context.watch<LocaleCubit>().state;
          return MaterialApp(
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            title: "The Maker's Market",
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: mode,
            home: _DemoSeeder(link: link, child: screenFor(link)),
          );
        },
      ),
    );
  }
}

/// Opens a screen from the web URL, e.g. `?screen=cart` or `?screen=product&id=3`.
Widget screenFor(Uri? link) {
  final params = link?.queryParameters ?? const {};
  switch (params['screen']) {
    case 'wishlist':
      return const Shell(initial: ShopTab.wishlist);
    case 'cart':
      return const Shell(initial: ShopTab.cart);
    case 'orders':
      return const Shell(initial: ShopTab.orders);
    case 'admin':
      return const AdminDashboard();
    case 'checkout':
      return const CheckoutScreen();
    case 'product':
      final id = int.tryParse(params['id'] ?? '');
      if (id != null) return ProductDetailsScreen(productId: id);
  }
  return const Shell();
}

/// With `?demo=1`, fills the cart, wishlist and orders from the catalog
/// once it loads, so the web demo can be explored without shopping first.
class _DemoSeeder extends StatelessWidget {
  const _DemoSeeder({required this.link, required this.child});

  final Uri? link;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (link?.queryParameters['demo'] != '1') return child;
    return BlocListener<ProductCubit, ProductState>(
      listenWhen: (a, b) => a.products.isEmpty && b.products.isNotEmpty,
      listener: (context, state) {
        final cart = context.read<CartCubit>();
        if (cart.state.items.isNotEmpty) return;
        final p = state.products;
        cart.add(p[0]);
        cart.add(p[4], quantity: 2);
        cart.add(p[8]);
        final wishlist = context.read<WishlistCubit>();
        for (final i in [1, 5, 9, 13]) {
          if (!wishlist.state.contains(p[i].id)) wishlist.toggle(p[i].id);
        }
        final orders = context.read<OrdersCubit>();
        if (orders.state.isEmpty) {
          orders.place(
            items: cart.state.items,
            summary: cart.state.summary,
            name: 'Demo Shopper',
            address: '12 Nile Street, Cairo',
            payment: 'Card',
          );
          orders.addAll(sampleOrders(p, DateTime.now()));
        }
      },
      child: child,
    );
  }
}
