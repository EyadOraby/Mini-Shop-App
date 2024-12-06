import 'package:corporatica_task_2/constants/app_routes.dart';
import 'package:corporatica_task_2/cubits/cart_cubit.dart';
import 'package:corporatica_task_2/cubits/product_cubit.dart';
import 'package:corporatica_task_2/cubits/quantity_cubit.dart';
import 'package:corporatica_task_2/models/cart_item_model.dart';
import 'package:corporatica_task_2/repositories/cart_repository.dart';
import 'package:corporatica_task_2/repositories/product_repository.dart';
import 'package:corporatica_task_2/screens/cart_screen.dart';
import 'package:corporatica_task_2/screens/product_details_screen.dart';
import 'package:corporatica_task_2/screens/product_list_screen.dart';
import 'package:corporatica_task_2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();

  Hive.init(appDocumentDirectory.path);

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
          )..fetchProducts(),
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
        title: 'Mini Shop App',
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
