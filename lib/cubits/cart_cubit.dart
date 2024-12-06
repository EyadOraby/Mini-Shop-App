import 'package:corporatica_task_2/main.dart';
import 'package:corporatica_task_2/models/cart_item_model.dart';
import 'package:corporatica_task_2/repositories/cart_repository.dart';
import 'package:corporatica_task_2/repositories/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartState {
  final List<CartItem>? cartItems;
  final String? errorMessage;
  final bool isLoading;

  CartState({this.cartItems, this.errorMessage, this.isLoading = true});
}

class CartCubit extends Cubit<CartState> {
  final ProductRepository repository;
  final CartRepository cartRepository;

  CartCubit({required this.repository, required this.cartRepository})
      : super(CartState());

  void fetchCartItems() async {
    try {
      emit(CartState(isLoading: true));
      final cartItems = await cartRepository.getCartItems();
      emit(CartState(cartItems: cartItems, isLoading: false));
    } catch (e) {
      emit(CartState(errorMessage: e.toString(), isLoading: false));
    }
  }

  void increaseQuantity(int productId) async {
    final cartItems = await cartRepository.getCartItems();
    final cartItem =
        cartItems.firstWhere((item) => item.productId == productId);
    final updatedItem = cartItem.copyWith(quantity: cartItem.quantity + 1);

    await cartRepository.updateCartItem(updatedItem);
    fetchCartItems();
  }

  void decreaseQuantity(int productId) async {
    final cartItems = await cartRepository.getCartItems();
    final cartItem =
        cartItems.firstWhere((item) => item.productId == productId);

    if (cartItem.quantity > 1) {
      final updatedItem = cartItem.copyWith(quantity: cartItem.quantity - 1);
      await cartRepository.updateCartItem(updatedItem);
    } else {
      await cartRepository.removeFromCart(cartItem);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('${cartItem.name} has been removed from the cart'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    fetchCartItems();
  }

  void addToCart(
      int productId, int quantity, String name, double price, String imageUrl) {
    final cartItem = CartItem(
        productId: productId,
        quantity: quantity,
        name: name,
        price: price,
        imageUrl: imageUrl);
    cartRepository.addToCart(cartItem);
    fetchCartItems();
  }

  void removeFromCart(CartItem cartItem) async {
    await cartRepository.removeFromCart(cartItem);
    fetchCartItems();
  }
}
