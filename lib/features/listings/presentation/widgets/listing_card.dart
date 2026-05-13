import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/entities/listing_entity.dart';

class ListingCard extends StatelessWidget {
  final ListingEntity listing;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ListingCard({
    super.key,
    required this.listing,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.listingDetail(listing.id)),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        SizedBox(
          height: AppDimensions.listingImageHeight,
          width: double.infinity,
          child: listing.imageUrls.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: listing.imageUrls.first,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.border),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.border,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppColors.textHint),
                  ),
                )
              : Container(
                  color: AppColors.border,
                  child: const Icon(Icons.image_outlined, color: AppColors.textHint, size: 40),
                ),
        ),
        Positioned(
          top: AppDimensions.sm,
          left: AppDimensions.sm,
          child: _TypeBadge(type: listing.listingType),
        ),
        if (onFavoriteToggle != null)
          Positioned(
            top: AppDimensions.xs,
            right: AppDimensions.xs,
            child: Material(
              color: Colors.white.withOpacity(0.9),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onFavoriteToggle,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.xs),
                  child: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 20,
                    color: isFavorite ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            _buildPriceText(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          if (listing.distanceKm != null)
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                Text(
                  AppHelpers.formatDistance(listing.distanceKm!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _buildPriceText() {
    switch (listing.listingType) {
      case 'rent':
        return listing.rentPricePerDay != null
            ? '${AppHelpers.formatPrice(listing.rentPricePerDay!)}/day'
            : 'Rent';
      case 'exchange':
        return 'Exchange';
      default:
        return listing.sellPrice != null
            ? AppHelpers.formatPrice(listing.sellPrice!)
            : 'Free';
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (type) {
      case 'rent':
        color = AppColors.rentBadge;
        label = 'Rent';
        break;
      case 'exchange':
        color = AppColors.exchangeBadge;
        label = 'Exchange';
        break;
      default:
        color = AppColors.sellBadge;
        label = 'Sell';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ListingCardHorizontal extends StatelessWidget {
  final ListingEntity listing;

  const ListingCardHorizontal({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.listingDetail(listing.id)),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: listing.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: listing.imageUrls.first,
                          fit: BoxFit.cover,
                        )
                      : Container(color: AppColors.border),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      listing.sellPrice != null
                          ? AppHelpers.formatPrice(listing.sellPrice!)
                          : listing.listingType == 'exchange'
                              ? 'Exchange'
                              : 'Rent',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            listing.area ?? listing.city ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
