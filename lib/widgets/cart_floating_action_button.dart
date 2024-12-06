import 'package:corporatica_task_2/constants/app_colors.dart';
import 'package:corporatica_task_2/constants/app_routes.dart';
import 'package:corporatica_task_2/cubits/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartFloatingActionButton extends StatelessWidget {
  const CartFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Material(
          color: AppColors.appBlue,
          elevation: 6,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.cartScreenRoute);
              context.read<CartCubit>().fetchCartItems();
            },
            child: const SizedBox(
              width: 60.0,
              height: 60.0,
              child: Icon(
                Icons.shopping_cart,
                color: AppColors.appWhite,
                size: 32.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
