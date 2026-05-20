import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/routes/app_pages.dart';
import '../../../../core/constants/app_colors.dart';

class Header extends StatelessWidget {
  final String title; // Judul halaman bisa dinamis (Nama User / Nama Fitur)

  const Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(Routes.PROFILE),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Get.toNamed(Routes.NOTIFICATION),
          icon: const Icon(Icons.notifications_none_outlined),
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}

// Widget Header() {

// }
