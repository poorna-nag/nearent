import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check the current state in case it resolved before this widget built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAuthState(context.read<AuthBloc>().state);
    });
  }

  Future<void> _handleAuthState(AuthState state) async {
    if (!mounted) return;
    if (state is AuthAuthenticated) {
      context.go(AppRoutes.home);
    } else if (state is AuthUnauthenticated) {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final onboardingDone = prefs.getBool(AppConstants.onboardingKey) ?? false;
      context.go(onboardingDone ? AppRoutes.login : AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _handleAuthState(state),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    letterSpacing: -1,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms),
                const SizedBox(height: 80),
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
                    .animate()
                    .fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
