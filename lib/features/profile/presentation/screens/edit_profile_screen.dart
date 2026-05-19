import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  File? _pickedImage;
  UserEntity? _user;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _user = authState.user;
      _nameController.text = _user!.name;
      _bioController.text = _user!.bio ?? '';
      _cityController.text = _user!.city ?? '';
      _areaController.text = _user!.area ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated || state is ProfileImageUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.profileUpdated)),
          );
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.editProfile),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            children: [
              _buildAvatarPicker(),
              const SizedBox(height: AppDimensions.xl),
              AppTextField(
                label: AppStrings.fullName,
                hint: 'Your full name',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                label: 'Bio',
                hint: 'Tell others about yourself',
                controller: _bioController,
                maxLength: 160,
                prefixIcon: const Icon(Icons.info_outline, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                label: 'City',
                hint: 'Your city',
                controller: _cityController,
                prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                label: 'Area / Locality',
                hint: 'Your area or locality',
                controller: _areaController,
                prefixIcon: const Icon(Icons.map_outlined, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.xxl),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) => AppButton(
                  text: AppStrings.save,
                  isLoading: state is ProfileLoading,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.primaryContainer,
            backgroundImage: _pickedImage != null
                ? FileImage(_pickedImage!)
                : (_user?.profileImageUrl != null
                    ? CachedNetworkImageProvider(_user!.profileImageUrl!)
                    : null) as ImageProvider?,
            child: (_pickedImage == null && _user?.profileImageUrl == null)
                ? const Icon(Icons.person_rounded, size: 48, color: AppColors.primary)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  void _save() {
    if (_user == null) return;
    if (_pickedImage != null) {
      context.read<ProfileBloc>().add(
        ProfileImageUploadRequested(userId: _user!.id, image: _pickedImage!),
      );
    }
    // Build updated user
    final updated = UserEntity(
      id: _user!.id,
      name: _nameController.text.trim(),
      email: _user!.email,
      phoneNumber: _user!.phoneNumber,
      profileImageUrl: _user!.profileImageUrl,
      bio: _bioController.text.trim(),
      city: _cityController.text.trim(),
      area: _areaController.text.trim(),
      latitude: _user!.latitude,
      longitude: _user!.longitude,
      rating: _user!.rating,
      ratingsCount: _user!.ratingsCount,
      listingsCount: _user!.listingsCount,
      trustScore: _user!.trustScore,
      role: _user!.role,
      isVerified: _user!.isVerified,
      isBlocked: _user!.isBlocked,
      createdAt: _user!.createdAt,
      lastSeen: _user!.lastSeen,
    );
    context.read<ProfileBloc>().add(ProfileUpdateRequested(updated));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }
}
