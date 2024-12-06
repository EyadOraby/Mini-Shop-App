// ignore_for_file: library_private_types_in_public_api

import 'package:corporatica_task_2/constants/app_colors.dart';
import 'package:corporatica_task_2/cubits/cart_cubit.dart';
import 'package:corporatica_task_2/cubits/quantity_cubit.dart';
import 'package:corporatica_task_2/models/product_model.dart';
import 'package:corporatica_task_2/widgets/quantity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
              height: 135,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.appGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<QuantityCubit, QuantityState>(
                    builder: (context, state) {
                  int quantity = state.quantity;

                  return QuantityWidget(
                    quantity: quantity,
                  );
                }),
                const SizedBox(height: 10),
                BlocBuilder<QuantityCubit, QuantityState>(
                    builder: (context, state) {
                  int quantity = state.quantity;

                  return AddToCartButton(product: product, quantity: quantity);
                })
              ],
            ),
          ),
        ],
      ),
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
    return SizedBox(
      width: double.infinity,
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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
  }
}
