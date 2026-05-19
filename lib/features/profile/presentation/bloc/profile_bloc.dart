import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileUpdateRequested>(_onUpdate);
    on<ProfileImageUploadRequested>(_onImageUpload);
  }

  Future<void> _onLoad(ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      final user = await _repository.getProfile(event.userId);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdate(ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      await _repository.updateProfile(event.user);
      emit(ProfileUpdated(event.user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onImageUpload(
    ProfileImageUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final url = await _repository.uploadProfileImage(event.userId, event.image);
      emit(ProfileImageUploaded(url));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
