---
name: Nearend project overview
description: Core facts about the Nearend Flutter app — architecture, app ID, Firebase setup, what's been built
type: project
---

Full Flutter app built from scratch. Community-driven local marketplace (sell/rent/exchange).

**Why:** User wants a production-ready startup-level app with clean architecture.

**How to apply:** When asked about any feature or fix, this is the full-stack Flutter/Firebase project — not a toy app.

## Key facts
- App name: Nearend (`com.nearend.app`)
- Architecture: Clean Architecture + BLoC (flutter_bloc)
- Router: go_router with ShellRoute for bottom nav
- Font: Poppins (must be added to assets/fonts/ manually, or switch to google_fonts)
- Firebase services: Auth, Firestore, Storage, Crashlytics, Analytics, FCM
- minSdk Android: 23; iOS deployment target: 13.0

## What was built (51 Dart files)
- core/: AppColors, AppTheme (light+dark), AppDimensions, AppStrings, AppConstants, validators, helpers, location_utils, AppButton, AppTextField, LoadingWidget/ShimmerBox/AppErrorWidget/AppEmptyWidget
- auth feature: UserModel, AuthRepositoryImpl (email/Google/phone), AuthBloc, SplashScreen, OnboardingScreen, LoginScreen, RegisterScreen, PhoneAuthScreen
- listings feature: ListingModel, ListingRepositoryImpl (geo queries, upload, favorites), ListingBloc, HomeScreen, ExploreScreen, ListingDetailScreen, AddListingScreen, ListingCard widgets
- chat feature: ChatModel/MessageModel, ChatRepositoryImpl (real-time Firestore streams), ChatBloc, ChatListScreen, ChatScreen (with image send, seen status)
- profile feature: ProfileScreen, DashboardScreen
- routes/: AppRouter, AppRoutes, MainShell (bottom nav), auxiliary screens (Settings, About, Help, Notifications, ForgotPassword)
- Firebase: firestore.rules, storage.rules, firestore.indexes.json, firebase.json, firestore_schema.md

## Still needed to run
1. Add google-services.json (Android) and GoogleService-Info.plist (iOS) from Firebase Console
2. Add Poppins TTF files to assets/fonts/
3. Set Google Maps API key in AndroidManifest.xml and Info.plist
4. Set iOS reversed client ID in Info.plist for Google Sign-In
5. Run `flutter pub get`
