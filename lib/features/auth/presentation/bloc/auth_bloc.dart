import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInWithEmailPassword>(_onSignInWithEmailPassword);
    on<AuthSignUpWithEmailPassword>(_onSignUpWithEmailPassword);
    on<AuthSignInWithGoogle>(_onSignInWithGoogle);
    on<AuthSendPhoneOtp>(_onSendPhoneOtp);
    on<AuthVerifyPhoneOtp>(_onVerifyPhoneOtp);
    on<AuthSignOut>(_onSignOut);
    on<AuthResetPassword>(_onResetPassword);
  }

  void _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) {
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithEmailPassword(
    AuthSignInWithEmailPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithEmailPassword(event.email, event.password);
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Sign in failed. Please try again.'));
    }
  }

  Future<void> _onSignUpWithEmailPassword(
    AuthSignUpWithEmailPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUpWithEmailPassword(
        event.email, event.password, event.name,
      );
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Registration failed. Please try again.'));
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Google sign-in failed. Please try again.'));
    }
  }

  Future<void> _onSendPhoneOtp(
    AuthSendPhoneOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final verificationId = await _authRepository.sendPhoneOtp(event.phoneNumber);
      emit(AuthOtpSent(verificationId: verificationId, phoneNumber: event.phoneNumber));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Failed to send OTP. Please try again.'));
    }
  }

  Future<void> _onVerifyPhoneOtp(
    AuthVerifyPhoneOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.verifyPhoneOtp(event.verificationId, event.otp);
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('OTP verification failed. Please try again.'));
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onResetPassword(
    AuthResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(const AuthPasswordResetSent());
    } catch (e) {
      emit(const AuthError('Failed to send reset email.'));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
