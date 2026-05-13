# Nearend — Local Community Marketplace

> Buy, Rent & Exchange items with people near you. Free. No fees. No delivery. Just community.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter + Dart |
| Architecture | Clean Architecture + MVVM/BLoC |
| Backend | Firebase |
| Auth | Firebase Auth (Email, Google, Phone OTP) |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| Notifications | Firebase Cloud Messaging |
| Maps | Google Maps Flutter + Geolocator |
| Routing | go_router |

---

## Project Structure

```
lib/
├── core/
│   ├── constants/      # AppColors, AppStrings, AppDimensions, AppConstants
│   ├── errors/         # Failures & exceptions (Clean Architecture)
│   ├── theme/          # Light & dark MaterialTheme (Poppins)
│   ├── utils/          # Validators, AppHelpers, LocationUtils
│   └── widgets/        # AppButton, AppTextField, LoadingWidget, shimmer, error/empty states
│
├── features/
│   ├── auth/
│   │   ├── data/       # UserModel, AuthRepositoryImpl (Firebase)
│   │   ├── domain/     # UserEntity, AuthRepository interface
│   │   └── presentation/  # AuthBloc + Splash, Onboarding, Login, Register, PhoneAuth screens
│   ├── listings/
│   │   ├── data/       # ListingModel, ListingRepositoryImpl
│   │   ├── domain/     # ListingEntity, ListingRepository interface
│   │   └── presentation/  # ListingBloc + Home, Explore, Detail, AddListing screens
│   ├── chat/
│   │   ├── data/       # ChatModel, MessageModel, ChatRepositoryImpl
│   │   ├── domain/     # ChatEntity, MessageEntity, ChatRepository interface
│   │   └── presentation/  # ChatBloc + ChatList, ChatScreen
│   └── profile/
│       └── presentation/  # ProfileScreen, DashboardScreen
│
├── routes/             # AppRouter (go_router) + MainShell (bottom nav) + aux screens
└── main.dart           # Firebase init, MultiBlocProvider, MaterialApp.router
```

---

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create project: `nearend`
3. Enable Google Analytics

### 2. Register Apps

**Android** — Package: `com.nearend.app`
- Download `google-services.json` → `android/app/google-services.json`

**iOS** — Bundle ID: `com.nearend.app`
- Download `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`

### 3. Enable Services

```
Firebase Console → Build:
✅ Authentication  → Email/Password, Google, Phone
✅ Firestore       → Production mode
✅ Storage         → Default bucket
✅ Cloud Messaging → (auto-enabled)
✅ Crashlytics     → Enable
✅ Analytics       → Enable
```

### 4. Deploy Rules & Indexes

```bash
npm install -g firebase-tools
firebase login
firebase use --add   # select your project
firebase deploy --only firestore:rules,firestore:indexes,storage
```

### 5. Google Maps API Key

Enable **Maps SDK for Android** and **Maps SDK for iOS** in Google Cloud Console.

- **Android:** Edit `android/app/src/main/AndroidManifest.xml`, replace `${MAPS_API_KEY}` or set in `android/local.properties`:
  ```
  MAPS_API_KEY=AIzaXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ```
- **iOS:** Replace `YOUR_GOOGLE_MAPS_API_KEY` in `ios/Runner/Info.plist`

### 6. Google Sign-In (iOS only)

In `ios/Runner/Info.plist`, replace `YOUR_REVERSED_CLIENT_ID` with the `REVERSED_CLIENT_ID` value from your `GoogleService-Info.plist`.

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK (Android)
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## Adding Poppins Font

The app uses Poppins loaded from local assets. Add these files to `assets/fonts/`:

```
Poppins-Regular.ttf
Poppins-Medium.ttf
Poppins-SemiBold.ttf
Poppins-Bold.ttf
```

Download from [fonts.google.com/specimen/Poppins](https://fonts.google.com/specimen/Poppins).

**Alternative:** Switch to the `google_fonts` package — replace the `fontFamily` declarations in `AppTheme` with `GoogleFonts.poppinsTextTheme()`.

---

## Key Features

| Feature | Status |
|---|---|
| Email / Password auth | ✅ |
| Google Sign-In | ✅ |
| Phone OTP verification | ✅ |
| Onboarding flow | ✅ |
| Nearby listings (geo-query) | ✅ |
| Category & type filters | ✅ |
| Full-text search | ✅ |
| Post listings (sell / rent / exchange) | ✅ |
| Multi-image upload to Firebase Storage | ✅ |
| Listing detail with image carousel | ✅ |
| Real-time 1:1 chat | ✅ |
| Chat image sharing | ✅ |
| Unread message badges | ✅ |
| Favorites / wishlist | ✅ |
| User profiles with stats | ✅ |
| Dashboard (my listings + saved) | ✅ |
| Report listings | ✅ |
| Dark mode | ✅ |
| Shimmer loading skeletons | ✅ |
| Smooth enter animations | ✅ |
| Firebase Security Rules | ✅ |
| Firestore composite indexes | ✅ |

---

## Architecture Diagram

```
┌─────────────────────────────────────┐
│  Presentation (Flutter Widgets)      │
│  BLoC (Events → States)             │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│  Domain Layer                        │
│  Entities / Repository Interfaces   │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│  Data Layer                          │
│  Repository Implementations         │
│  Firestore / Storage Models         │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│  Firebase                            │
│  Auth · Firestore · Storage · FCM   │
└─────────────────────────────────────┘
```

---

## Platform Requirements

| Platform | Minimum |
|---|---|
| Android | API 23 (Android 6.0) |
| iOS | 13.0 |
