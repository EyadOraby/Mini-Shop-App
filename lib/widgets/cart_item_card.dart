// ignore_for_file: unused_element

import 'package:corporatica_task_2/constants/app_colors.dart';
import 'package:corporatica_task_2/cubits/cart_cubit.dart';
import 'package:corporatica_task_2/models/cart_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  const CartItemCard({super.key, required this.cartItem});

  Future<void> _showDeleteDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text(
              'Are you sure you want to remove ${cartItem.name} from the cart?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                context.read<CartCubit>().removeFromCart(cartItem);
                Navigator.of(context).pop();
              },
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.appRed)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              cartItem.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            cartItem.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          subtitle: Text(
            '\$${cartItem.price} x ${cartItem.quantity}',
            style: const TextStyle(fontSize: 14.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove,
                  size: 20.0,
                ),
                onPressed: () {
                  context
                      .read<CartCubit>()
                      .decreaseQuantity(cartItem.productId);
                },
              ),
              Text(
                '${cartItem.quantity}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 20.0,
                ),
                onPressed: () {
                  context
                      .read<CartCubit>()
                      .increaseQuantity(cartItem.productId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
