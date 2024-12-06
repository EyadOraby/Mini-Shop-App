import 'package:corporatica_task_2/widgets/appBar_widget.dart';
import 'package:corporatica_task_2/widgets/cart_item_card.dart';
import 'package:corporatica_task_2/widgets/total_cart_price_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:corporatica_task_2/cubits/cart_cubit.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: "Your Cart"),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.cartItems == null || state.cartItems!.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          } else {
            double totalPrice = 0.0;
            for (var item in state.cartItems!) {
              totalPrice += item.price * item.quantity;
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: state.cartItems!.length,
                    itemBuilder: (context, index) {
                      final cartItem = state.cartItems![index];
                      return CartItemCard(cartItem: cartItem);
                    },
                  ),
                ),
                TotalCartPriceWidget(totalPrice: totalPrice),
              ],
            );
          }
        },
      ),
    );
  }
}
