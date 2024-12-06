// ignore_for_file: prefer_const_constructors

import 'package:corporatica_task_2/constants/app_colors.dart';
import 'package:corporatica_task_2/cubits/product_cubit.dart';
import 'package:corporatica_task_2/screens/product_details_screen.dart';
import 'package:corporatica_task_2/widgets/appBar_widget.dart';
import 'package:corporatica_task_2/widgets/cart_floating_action_button.dart';
import 'package:corporatica_task_2/widgets/loading_indicator.dart';
import 'package:corporatica_task_2/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Scaffold(
      appBar: AppBarWidget(title: "Products"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                context.read<ProductCubit>().filterProducts(value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                labelText: 'Search Products',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                filled: true,
                fillColor: AppColors.appSearchTextColor,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const LoadingIndicator();
                }

                if (state.errorMessage != null) {
                  return Center(
                    child: Text(state.errorMessage!),
                  );
                }

                if (state.filteredProducts.isNotEmpty) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.5,
                    ),
                    itemCount: state.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = state.filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(
                                productId: product.id,
                              ),
                            ),
                          );
                        },
                        child: ProductCard(product: product),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No products found.',
                        style:
                            TextStyle(fontSize: 18, color: AppColors.appGrey)),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CartFloatingActionButton(),
    );
  }
}
