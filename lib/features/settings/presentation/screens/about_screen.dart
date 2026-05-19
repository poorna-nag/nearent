import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.about),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.splashGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 48),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Center(
              child: Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const Center(
              child: Text('Version 1.0.0', style: TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(
              'Nearend is a free community-driven local marketplace for buying, renting, and exchanging items nearby. We promote sustainability and local community connections.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
