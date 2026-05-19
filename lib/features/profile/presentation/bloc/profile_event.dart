import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  final UserEntity user;
  const ProfileUpdateRequested(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileImageUploadRequested extends ProfileEvent {
  final String userId;
  final File image;
  const ProfileImageUploadRequested({required this.userId, required this.image});
  @override
  List<Object?> get props => [userId];
}
