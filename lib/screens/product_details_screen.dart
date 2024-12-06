import 'package:corporatica_task_2/constants/app_colors.dart';
import 'package:corporatica_task_2/cubits/cart_cubit.dart';
import 'package:corporatica_task_2/cubits/product_cubit.dart';
import 'package:corporatica_task_2/cubits/quantity_cubit.dart';
import 'package:corporatica_task_2/models/product_model.dart';
import 'package:corporatica_task_2/widgets/appBar_widget.dart';
import 'package:corporatica_task_2/widgets/cart_floating_action_button.dart';
import 'package:corporatica_task_2/widgets/loading_indicator.dart';
import 'package:corporatica_task_2/widgets/quantity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    context.read<ProductCubit>().fetchProductById(widget.productId);

    return Scaffold(
      appBar: const AppBarWidget(title: "Product Details"),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingIndicator();
          }

          if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          }

          final product = state.productDetails;

          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                Text(
                  product.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Divider(),
                Text(
                  'Category: ${product.category}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                const Divider(),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '\$${product.price}',
                    style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.appGreen,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocBuilder<QuantityCubit, QuantityState>(
                        builder: (context, state) {
                      int quantity = state.quantity;

                      return QuantityWidget(
                        quantity: quantity,
                      );
                    }),
                    const SizedBox(height: 16),
                    BlocBuilder<QuantityCubit, QuantityState>(
                        builder: (context, state) {
                      int quantity = state.quantity;

                      return AddToCartButton(
                          product: product, quantity: quantity);
                    }),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      floatingActionButton: const CartFloatingActionButton(),
    );
  }
}

class AddToCartButton extends StatelessWidget {
  final Product product;
  final int quantity;
  const AddToCartButton(
      {super.key, required this.product, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          context.read<CartCubit>().addToCart(
                product.id,
                quantity,
                product.title,
                product.price,
                product.image,
              );
          context.read<CartCubit>().fetchCartItems();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 44),
        ),
        child: const Text(
          'Add to Cart',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.appWhite,
          ),
        ),
      ),
    );
    ;
  }
}
