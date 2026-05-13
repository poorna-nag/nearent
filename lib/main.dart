import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/listings/data/repositories/listing_repository_impl.dart';
import 'features/listings/presentation/bloc/listing_bloc.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  // Catch Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const NearendApp());
}

class NearendApp extends StatefulWidget {
  const NearendApp({super.key});

  @override
  State<NearendApp> createState() => _NearendAppState();
}

class _NearendAppState extends State<NearendApp> {
  // Services
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _googleSignIn = GoogleSignIn();
  final _uuid = const Uuid();

  late final _authRepo = AuthRepositoryImpl(
    auth: _auth,
    firestore: _firestore,
    googleSignIn: _googleSignIn,
  );

  late final _listingRepo = ListingRepositoryImpl(
    firestore: _firestore,
    storage: _storage,
    uuid: _uuid,
  );

  late final _chatRepo = ChatRepositoryImpl(
    firestore: _firestore,
    storage: _storage,
    uuid: _uuid,
  );

  late final _authBloc = AuthBloc(authRepository: _authRepo)
    ..add(const AuthCheckRequested());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(
          create: (_) => ListingBloc(repository: _listingRepo),
        ),
        BlocProvider(
          create: (_) => ChatBloc(repository: _chatRepo),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.createRouter(context);
          return MaterialApp.router(
            title: 'Nearend',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }
}
