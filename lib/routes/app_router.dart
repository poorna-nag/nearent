import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/phone_auth_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/chat/presentation/screens/chat_list_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/listings/presentation/screens/add_listing_screen.dart';
import '../features/listings/presentation/screens/explore_screen.dart';
import '../features/listings/presentation/screens/home_screen.dart';
import '../features/listings/presentation/screens/listing_detail_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/dashboard_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/help_center_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      redirect: (context, state) async {
        final authState = context.read<AuthBloc>().state;
        final prefs = await SharedPreferences.getInstance();
        final onboardingDone = prefs.getBool(AppConstants.onboardingKey) ?? false;

        final isOnSplash = state.matchedLocation == AppRoutes.splash;
        final authRoutes = [
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.onboarding,
          AppRoutes.phoneAuth,
          AppRoutes.forgotPassword,
        ];
        final isOnAuth = authRoutes.contains(state.matchedLocation);

        if (isOnSplash) return null;

        if (authState is AuthAuthenticated) {
          if (isOnAuth) return AppRoutes.home;
          return null;
        }
        if (authState is AuthUnauthenticated) {
          if (!onboardingDone) return AppRoutes.onboarding;
          if (!isOnAuth) return AppRoutes.login;
        }
        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
        GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
        GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
        GoRoute(path: AppRoutes.phoneAuth, builder: (_, __) => const PhoneAuthScreen()),
        GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
            GoRoute(path: AppRoutes.explore, builder: (_, __) => const ExploreScreen()),
            GoRoute(path: '/chats', builder: (_, __) => const ChatListScreen()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
        GoRoute(path: AppRoutes.addListing, builder: (_, __) => const AddListingScreen()),
        GoRoute(
          path: '/listing/:id',
          builder: (_, state) =>
              ListingDetailScreen(listingId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/listing/:id/edit', builder: (_, __) => const AddListingScreen()),
        GoRoute(
          path: '/user/:id',
          builder: (_, state) => ProfileScreen(userId: state.pathParameters['id']),
        ),
        GoRoute(
          path: AppRoutes.chat,
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return ChatScreen(
              currentUserId: extra['currentUserId'] ?? '',
              otherUserId: extra['otherUserId'] ?? '',
              chatId: extra['chatId'],
              listingId: extra['listingId'],
              listingTitle: extra['listingTitle'],
              listingImageUrl: extra['listingImageUrl'],
            );
          },
        ),
        GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
        GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
        GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
        GoRoute(path: AppRoutes.editProfile, builder: (_, __) => const EditProfileScreen()),
        GoRoute(path: AppRoutes.help, builder: (_, __) => const HelpCenterScreen()),
        GoRoute(path: AppRoutes.about, builder: (_, __) => const AboutScreen()),
      ],
    );
  }
}

// ─── Main Shell with Bottom Navigation ───────────────────────────────────────

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _tabs = [AppRoutes.home, AppRoutes.explore, '/chats', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          context.go(_tabs[i]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
