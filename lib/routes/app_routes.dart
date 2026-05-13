class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String phoneAuth = '/phone-auth';

  static const String home = '/home';
  static const String explore = '/explore';
  static const String addListing = '/add-listing';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String about = '/about';
  static const String favorites = '/favorites';
  static const String dashboard = '/dashboard';
  static const String editProfile = '/edit-profile';
  static const String chat = '/chat';

  static String listingDetail(String id) => '/listing/$id';
  static String editListing(String id) => '/listing/$id/edit';
  static String userProfile(String id) => '/user/$id';
}
