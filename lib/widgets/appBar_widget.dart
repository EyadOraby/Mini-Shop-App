// ignore_for_file: file_names

import 'package:corporatica_task_2/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title;
  const AppBarWidget(
      {super.key,
      required this.title,
      this.preferredSize = const Size.fromHeight(kToolbarHeight)});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.appBlueAccent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.appBlue, AppColors.appGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
