import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthSignInWithEmailPassword extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInWithEmailPassword({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpWithEmailPassword extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthSignUpWithEmailPassword({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, password];
}

class AuthSignInWithGoogle extends AuthEvent {
  const AuthSignInWithGoogle();
}

class AuthSendPhoneOtp extends AuthEvent {
  final String phoneNumber;
  const AuthSendPhoneOtp(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyPhoneOtp extends AuthEvent {
  final String verificationId;
  final String otp;
  const AuthVerifyPhoneOtp({required this.verificationId, required this.otp});
  @override
  List<Object?> get props => [verificationId, otp];
}

class AuthSignOut extends AuthEvent {
  const AuthSignOut();
}

class AuthResetPassword extends AuthEvent {
  final String email;
  const AuthResetPassword(this.email);
  @override
  List<Object?> get props => [email];
}
