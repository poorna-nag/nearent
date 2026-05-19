import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  const ProfileLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileUpdated extends ProfileState {
  final UserEntity user;
  const ProfileUpdated(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileImageUploaded extends ProfileState {
  final String imageUrl;
  const ProfileImageUploaded(this.imageUrl);
  @override
  List<Object?> get props => [imageUrl];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
