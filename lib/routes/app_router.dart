import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/onboarding_screen.dart';
import '../features/auth/presentation/pages/phone_auth_screen.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/pages/splash_screen.dart';
import '../features/chat/presentation/pages/chat_list_screen.dart';
import '../features/chat/presentation/pages/chat_screen.dart';
import '../features/listings/presentation/pages/add_listing_screen.dart';
import '../features/listings/presentation/pages/explore_screen.dart';
import '../features/listings/presentation/pages/home_screen.dart';
import '../features/listings/presentation/pages/listing_detail_screen.dart';
import '../features/profile/presentation/pages/dashboard_screen.dart';
import '../features/profile/presentation/pages/profile_screen.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_colors.dart';
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
          builder: (_, state) => ListingDetailScreen(listingId: state.pathParameters['id']!),
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
      ),
    );
  }
}

// ─── Supporting Screens ───────────────────────────────────────────────────────

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(
        child: Text('Notifications coming soon', style: TextStyle(color: Color(0xFF6B7280))),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            value: isDark,
            onChanged: (_) {},
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
          const ListTile(
            leading: Icon(Icons.language_outlined),
            title: Text('Language'),
            subtitle: Text('English'),
            trailing: Icon(Icons.chevron_right_rounded),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications'),
            trailing: Icon(Icons.chevron_right_rounded),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: const Center(child: Text('Edit profile')),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your email and we'll send a reset link.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => ElevatedButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  if (email.isNotEmpty) {
                    context.read<AuthBloc>().add(AuthResetPassword(email));
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: state is AuthLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Send Reset Email'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FaqItem(
            question: 'How do I post a listing?',
            answer: 'Tap the + button on the home screen and fill in your item details.',
          ),
          _FaqItem(
            question: 'Is there any fee?',
            answer: 'No! Nearend is completely free. No commission or fees.',
          ),
          _FaqItem(
            question: 'How do I contact a seller?',
            answer: 'Open a listing and tap "Contact Seller" to start a chat.',
          ),
          _FaqItem(
            question: 'How is my location used?',
            answer: 'Location is used to show nearby items. It\'s never shared without consent.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer),
        ),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Nearend')),
      body: Padding(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Nearend',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Center(
              child: Text('Version 1.0.0', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            const SizedBox(height: 32),
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
