import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity> signInWithEmailPassword(String email, String password);
  Future<UserEntity> signUpWithEmailPassword(String email, String password, String name);
  Future<UserEntity> signInWithGoogle();
  Future<String> sendPhoneOtp(String phoneNumber);
  Future<UserEntity> verifyPhoneOtp(String verificationId, String otp);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<void> updateUserProfile(UserEntity user);
  Future<void> sendPasswordResetEmail(String email);
}
