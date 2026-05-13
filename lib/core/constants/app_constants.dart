class AppConstants {
  AppConstants._();

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String listingsCollection = 'listings';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String favoritesCollection = 'favorites';
  static const String reportsCollection = 'reports';
  static const String notificationsCollection = 'notifications';

  // Firebase Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String listingImagesPath = 'listing_images';
  static const String chatImagesPath = 'chat_images';

  // Search & Discovery
  static const double defaultSearchRadius = 10.0; // km
  static const double maxSearchRadius = 50.0;
  static const int nearbyListingsLimit = 20;
  static const int paginationLimit = 15;

  // Cache
  static const int imageCacheDays = 7;

  // Listing
  static const int maxListingImages = 8;
  static const int maxTitleLength = 80;
  static const int maxDescriptionLength = 500;

  // Chat
  static const int chatMessageLimit = 50;

  // Shared Prefs Keys
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_complete';
  static const String userIdKey = 'user_id';

  // Categories
  static const List<String> categories = [
    'All',
    'Clothes',
    'Mobiles',
    'Laptops',
    'Electronics',
    'Furniture',
    'Sports',
    'Books',
    'Accessories',
    'Vehicles',
    'Appliances',
    'Others',
  ];

  // Category Icons (Material icon names mapped to categories)
  static const Map<String, String> categoryIcons = {
    'All': 'grid_view',
    'Clothes': 'checkroom',
    'Mobiles': 'smartphone',
    'Laptops': 'laptop',
    'Electronics': 'devices',
    'Furniture': 'chair',
    'Sports': 'sports_soccer',
    'Books': 'menu_book',
    'Accessories': 'watch',
    'Vehicles': 'directions_bike',
    'Appliances': 'kitchen',
    'Others': 'more_horiz',
  };

  // Conditions
  static const List<String> conditions = [
    'Brand New',
    'Like New',
    'Good',
    'Fair',
    'Poor',
  ];

  // Listing Types
  static const String listingTypeSell = 'sell';
  static const String listingTypeRent = 'rent';
  static const String listingTypeExchange = 'exchange';

  // Admin
  static const String adminRole = 'admin';
  static const String userRole = 'user';

  // GeoHash precision
  static const int geoHashPrecision = 9;

  // OTP
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;
}
