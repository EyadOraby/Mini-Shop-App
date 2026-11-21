import 'package:mini_shop/constants/app_routes.dart';
import 'package:mini_shop/cubits/cart_cubit.dart';
import 'package:mini_shop/cubits/product_cubit.dart';
import 'package:mini_shop/cubits/quantity_cubit.dart';
import 'package:mini_shop/models/cart_item_model.dart';
import 'package:mini_shop/repositories/cart_repository.dart';
import 'package:mini_shop/repositories/product_repository.dart';
import 'package:mini_shop/screens/cart_screen.dart';
import 'package:mini_shop/screens/product_details_screen.dart';
import 'package:mini_shop/screens/product_list_screen.dart';
import 'package:mini_shop/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Works on Android, iOS, desktop and the web (IndexedDB).
  await Hive.initFlutter();

  Hive.registerAdapter(CartItemAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductCubit(
            repository: ProductRepository(apiService: ApiService()),
          ),
        ),
        BlocProvider(
          create: (context) => CartCubit(
              repository: ProductRepository(apiService: ApiService()),
              cartRepository: CartRepository()),
        ),
        BlocProvider(
          create: (context) => QuantityCubit(),
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Mini Shop',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF4FB6A3),
          brightness: Brightness.light,
        ),
        initialRoute: AppRoutes.productListScreenRoute,
        routes: {
          AppRoutes.productListScreenRoute: (context) =>
              const ProductListScreen(),
          AppRoutes.productDetailsScreenRoute: (context) =>
              ProductDetailsScreen(
                  productId: ModalRoute.of(context)!.settings.arguments as int),
          AppRoutes.cartScreenRoute: (context) => const CartScreen(),
        },
      ),
    );
  }
}
