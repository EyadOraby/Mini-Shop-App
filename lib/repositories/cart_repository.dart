import 'package:corporatica_task_2/constants/app_colors.dart';
import 'package:corporatica_task_2/main.dart';
import 'package:corporatica_task_2/models/cart_item_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CartRepository {
  Future<void> updateCartItem(CartItem cartItem) async {
    final box = await Hive.openBox<CartItem>('cartBox');
    final existingItem = box.get(cartItem.productId);

    if (existingItem != null) {
      final updatedItem = existingItem.copyWith(quantity: cartItem.quantity);
      await box.put(cartItem.productId, updatedItem);
    } else {
      await box.put(cartItem.productId, cartItem);
    }
  }

  Future<List<CartItem>> getCartItems() async {
    final box = await Hive.openBox<CartItem>('cartBox');
    return box.values.toList();
  }

  Future<void> addToCart(CartItem cartItem) async {
    try {
      final box = await Hive.openBox<CartItem>('cartBox');
      final existingItem = box.get(cartItem.productId);

      if (existingItem != null) {
        final updatedItem = existingItem.copyWith(
          quantity: cartItem.quantity + existingItem.quantity,
        );
        await box.put(cartItem.productId, updatedItem);

        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('${cartItem.name} updated in cart'),
            backgroundColor: AppColors.appGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        await box.put(cartItem.productId, cartItem);

        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('${cartItem.name} added to cart'),
            backgroundColor: AppColors.appGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Error adding item to cart: $e'),
          backgroundColor: AppColors.appRed,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> removeFromCart(CartItem cartItem) async {
    final box = await Hive.openBox<CartItem>('cartBox');
    await box.delete(cartItem.productId);

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('${cartItem.name} has been removed from the cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
