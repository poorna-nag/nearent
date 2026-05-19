import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    context.read<ListingBloc>().add(ListingLoadById(widget.listingId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ListingBloc, ListingState>(
      listener: (context, state) {
        if (state is ListingDetailLoaded) {
          setState(() => _isFavorite = state.isFavorite);
        }
      },
      builder: (context, state) {
        if (state is ListingLoading) return const Scaffold(body: LoadingWidget());
        if (state is ListingError) {
          return Scaffold(
            appBar: AppBar(),
            body: AppErrorWidget(message: state.message),
          );
        }
        if (state is ListingDetailLoaded) {
          return _buildDetail(context, state);
        }
        return const Scaffold(body: LoadingWidget());
      },
    );
  }

  Widget _buildDetail(BuildContext context, ListingDetailLoaded state) {
    final listing = state.listing;
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.id : null;
    final isOwner = currentUserId == listing.sellerId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(listing, currentUserId),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeAndCondition(context, listing),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: AppDimensions.sm),
                  _buildPriceRow(context, listing),
                  const Divider(height: AppDimensions.xl),
                  _buildSellerInfo(context, listing, currentUserId, isOwner),
                  const Divider(height: AppDimensions.xl),
                  _buildDescription(context, listing),
                  const Divider(height: AppDimensions.xl),
                  _buildDetails(context, listing),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isOwner
          ? null
          : _buildBottomBar(context, listing, currentUserId),
    );
  }

  Widget _buildSliverAppBar(listing, String? currentUserId) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(AppDimensions.xs),
        child: CircleAvatar(
          backgroundColor: Colors.black38,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.xs),
          child: CircleAvatar(
            backgroundColor: Colors.black38,
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? AppColors.error : Colors.white,
                size: 20,
              ),
              onPressed: currentUserId != null
                  ? () {
                      setState(() => _isFavorite = !_isFavorite);
                      context.read<ListingBloc>().add(ListingToggleFavorite(
                        listingId: widget.listingId,
                        userId: currentUserId,
                      ));
                    }
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.xs),
          child: CircleAvatar(
            backgroundColor: Colors.black38,
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
              onPressed: () => Share.share(
                'Check out this listing on Nearend!',
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            CarouselSlider.builder(
              itemCount: (listing.imageUrls as List).isNotEmpty
                  ? (listing.imageUrls as List).length
                  : 1,
              options: CarouselOptions(
                height: 300,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (i, _) => setState(() => _currentImageIndex = i),
              ),
              itemBuilder: (context, i, _) {
                if ((listing.imageUrls as List).isEmpty) {
                  return Container(color: AppColors.border);
                }
                return CachedNetworkImage(
                  imageUrl: listing.imageUrls[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
            if ((listing.imageUrls as List).length > 1)
              Positioned(
                bottom: AppDimensions.md,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: _currentImageIndex,
                    count: (listing.imageUrls as List).length,
                    effect: const WormEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white54,
                      dotHeight: 6,
                      dotWidth: 6,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeAndCondition(context, listing) {
    return Wrap(
      spacing: AppDimensions.sm,
      children: [
        _chip(listing.listingType.toUpperCase(), AppColors.primary),
        _chip(listing.condition, AppColors.secondary),
        if (!listing.isAvailable) _chip('SOLD', AppColors.error),
      ],
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriceRow(context, listing) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (listing.sellPrice != null)
                Text(
                  AppHelpers.formatPrice(listing.sellPrice!),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              if (listing.rentPricePerDay != null)
                Text(
                  '${AppHelpers.formatPrice(listing.rentPricePerDay!)}/day',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.rentBadge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (listing.isForExchange)
                Text(
                  'Open for Exchange',
                  style: TextStyle(
                    color: AppColors.exchangeBadge,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        if (listing.distanceKm != null)
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Text(
                AppHelpers.formatDistance(listing.distanceKm!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSellerInfo(context, listing, String? currentUserId, bool isOwner) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.userProfile(listing.sellerId)),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppDimensions.avatarMd / 2,
            backgroundColor: AppColors.primaryContainer,
            backgroundImage: listing.sellerImageUrl != null
                ? CachedNetworkImageProvider(listing.sellerImageUrl!)
                : null,
            child: listing.sellerImageUrl == null
                ? Text(
                    AppHelpers.getInitials(listing.sellerName),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.sellerName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      listing.sellerRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (listing.area != null || listing.city != null) ...[
                      const SizedBox(width: AppDimensions.sm),
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.textSecondary),
                      Text(
                        listing.area ?? listing.city ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }

  Widget _buildDescription(context, listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          listing.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(context, listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        _detailRow(context, 'Category', listing.category),
        _detailRow(context, 'Condition', listing.condition),
        _detailRow(context, 'Listed', AppHelpers.timeAgo(listing.createdAt)),
        _detailRow(context, 'Views', '${listing.viewCount}'),
      ],
    );
  }

  Widget _detailRow(context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(context, listing, String? currentUserId) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (listing.isForExchange)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _contactSeller(listing, currentUserId),
                  child: const Text(AppStrings.requestExchange),
                ),
              ),
            if (listing.isForExchange) const SizedBox(width: AppDimensions.sm),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _contactSeller(listing, currentUserId),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text(AppStrings.contactSeller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactSeller(listing, String? currentUserId) {
    if (currentUserId == null) {
      context.push(AppRoutes.login);
      return;
    }
    context.push(AppRoutes.chat, extra: {
      'currentUserId': currentUserId,
      'otherUserId': listing.sellerId,
      'listingId': listing.id,
      'listingTitle': listing.title,
      'listingImageUrl': listing.imageUrls.isNotEmpty ? listing.imageUrls.first : null,
    });
  }
}
