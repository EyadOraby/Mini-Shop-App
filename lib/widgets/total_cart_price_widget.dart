import 'package:corporatica_task_2/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TotalCartPriceWidget extends StatelessWidget {
  final double totalPrice;
  const TotalCartPriceWidget({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: AppColors.appBlue,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total:',
              style: TextStyle(
                fontSize: 18.0,
                color: AppColors.appWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18.0,
                color: AppColors.appWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
