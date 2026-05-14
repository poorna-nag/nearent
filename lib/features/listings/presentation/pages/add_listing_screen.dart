import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/listing_entity.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _rentPriceController = TextEditingController();

  String _listingType = AppConstants.listingTypeSell;
  String _category = 'Electronics';
  String _condition = 'Good';
  bool _isForExchange = false;
  final List<File> _selectedImages = [];
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListingBloc, ListingState>(
      listener: (context, state) {
        if (state is ListingCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.listingAdded),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
        if (state is ListingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.addNewListing),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.md),
            children: [
              _buildImagePicker().animate().fadeIn(),
              const SizedBox(height: AppDimensions.lg),
              _buildListingTypeSelector().animate().fadeIn(delay: 100.ms),
              const SizedBox(height: AppDimensions.lg),
              AppTextField(
                label: AppStrings.productTitle,
                hint: 'e.g. iPhone 13 Pro Max',
                controller: _titleController,
                validator: Validators.listingTitle,
                maxLength: AppConstants.maxTitleLength,
                textInputAction: TextInputAction.next,
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                label: AppStrings.description,
                hint: 'Describe your item in detail...',
                controller: _descriptionController,
                validator: (v) => Validators.required(v, 'Description'),
                maxLines: 4,
                maxLength: AppConstants.maxDescriptionLength,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: AppDimensions.lg),
              _buildPriceFields().animate().fadeIn(delay: 250.ms),
              const SizedBox(height: AppDimensions.lg),
              _buildDropdowns().animate().fadeIn(delay: 300.ms),
              const SizedBox(height: AppDimensions.xl),
              BlocBuilder<ListingBloc, ListingState>(
                builder: (context, state) => AppButton(
                  text: 'Post Listing',
                  isLoading: state is ListingLoading,
                  onPressed: _submit,
                ),
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: AppDimensions.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.addPhotos,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
            itemBuilder: (context, i) {
              if (i == _selectedImages.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined,
                            color: AppColors.textSecondary),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedImages.length}/${AppConstants.maxListingImages}',
                          style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: Image.file(
                      _selectedImages[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImages.removeAt(i)),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListingTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.listingType,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            _typeButton(AppConstants.listingTypeSell, AppStrings.sell, AppColors.sellBadge),
            const SizedBox(width: AppDimensions.sm),
            _typeButton(AppConstants.listingTypeRent, AppStrings.rent, AppColors.rentBadge),
            const SizedBox(width: AppDimensions.sm),
            _typeButton(AppConstants.listingTypeExchange, AppStrings.exchange, AppColors.exchangeBadge),
          ],
        ),
        if (_listingType == AppConstants.listingTypeSell ||
            _listingType == AppConstants.listingTypeRent) ...[
          const SizedBox(height: AppDimensions.md),
          CheckboxListTile(
            value: _isForExchange,
            onChanged: (v) => setState(() => _isForExchange = v ?? false),
            title: const Text('Also open for exchange'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ],
    );
  }

  Widget _typeButton(String type, String label, Color color) {
    final isSelected = _listingType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _listingType = type),
        child: AnimatedContainer(
          duration: 200.ms,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        if (_listingType == AppConstants.listingTypeSell ||
            _listingType == AppConstants.listingTypeExchange)
          Expanded(
            child: AppTextField(
              label: '${AppStrings.price} (₹)',
              hint: '0',
              controller: _sellPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.price,
              prefixIcon: const Icon(Icons.currency_rupee_rounded,
                  color: AppColors.textSecondary, size: 18),
            ),
          ),
        if (_listingType == AppConstants.listingTypeRent) ...[
          Expanded(
            child: AppTextField(
              label: '${AppStrings.rentPrice} (₹)',
              hint: '0',
              controller: _rentPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.price,
              prefixIcon: const Icon(Icons.currency_rupee_rounded,
                  color: AppColors.textSecondary, size: 18),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            label: AppStrings.category,
            value: _category,
            items: AppConstants.categories.where((c) => c != 'All').toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: _buildDropdown(
            label: AppStrings.condition,
            value: _condition,
            items: AppConstants.conditions,
            onChanged: (v) => setState(() => _condition = v!),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md, vertical: AppDimensions.sm,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= AppConstants.maxListingImages) return;
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        final remaining = AppConstants.maxListingImages - _selectedImages.length;
        _selectedImages.addAll(
          images.take(remaining).map((xf) => File(xf.path)),
        );
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final user = authState.user;
    double? lat, lng;

    try {
      final position = await LocationUtils.getCurrentPosition();
      lat = position.latitude;
      lng = position.longitude;
    } catch (_) {
      lat = 0.0;
      lng = 0.0;
    }

    final listing = ListingEntity(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrls: [],
      sellPrice: _listingType != AppConstants.listingTypeRent
          ? double.tryParse(_sellPriceController.text)
          : null,
      rentPricePerDay: _listingType == AppConstants.listingTypeRent
          ? double.tryParse(_rentPriceController.text)
          : null,
      isForExchange: _isForExchange || _listingType == AppConstants.listingTypeExchange,
      category: _category,
      condition: _condition,
      listingType: _listingType,
      sellerId: user.id,
      sellerName: user.name,
      sellerImageUrl: user.profileImageUrl,
      sellerRating: user.rating,
      latitude: lat,
      longitude: lng,
      city: user.city,
      area: user.area,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (mounted) {
      context.read<ListingBloc>().add(ListingCreate(listing: listing, images: _selectedImages));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _sellPriceController.dispose();
    _rentPriceController.dispose();
    super.dispose();
  }
}
