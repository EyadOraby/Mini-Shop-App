import 'package:corporatica_task_2/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:corporatica_task_2/cubits/quantity_cubit.dart';

class QuantityWidget extends StatelessWidget {
  final int quantity;
  const QuantityWidget({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.appRed,
          onPressed: () {
            context.read<QuantityCubit>().decrement();
          },
        ),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.appQuantityTextColor,
              width: 1,
            ),
          ),
          child: Text(
            '$quantity',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.appGreen,
          onPressed: () {
            context.read<QuantityCubit>().increment();
          },
        ),
      ],
    );
  }
}
