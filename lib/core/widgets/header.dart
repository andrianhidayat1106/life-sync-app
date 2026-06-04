import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/routes/app_pages.dart';
import 'package:lifesync_app/core/services/cache_service.dart';
import '../../../../core/constants/app_colors.dart';

class Header extends StatelessWidget {
  final String title;

  const Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final cacheService = Get.find<CacheService>();
    final cachedName = cacheService.read<String>('user_fullname') ?? title;
    final cachedImagePath = cacheService.read<String>('user_profile_picture') ?? '';

    Widget profileImage;
    if (cachedImagePath.isNotEmpty && File(cachedImagePath).existsSync()) {
      profileImage = CircleAvatar(
        radius: 20,
        backgroundImage: FileImage(File(cachedImagePath)),
      );
    } else {
      profileImage = CircleAvatar(
        radius: 20,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: SvgPicture.asset(
            'assets/images/user.svg',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(Routes.PROFILE),
              child: Row(
                children: [
                  profileImage,
                  const SizedBox(width: 12),
                  Text(
                    cachedName,
                    style: const TextStyle(
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
