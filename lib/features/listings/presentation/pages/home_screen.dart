import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';
import '../widgets/listing_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _position;
  String _selectedCategory = 'All';
  double _radius = AppConstants.defaultSearchRadius;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await LocationUtils.getCurrentPosition();
      setState(() => _position = position);
      _loadNearby();
    } catch (_) {
      context.read<ListingBloc>().add(const ListingLoadTrending());
    }
  }

  void _loadNearby() {
    if (_position == null) return;
    context.read<ListingBloc>().add(ListingLoadNearby(
      lat: _position!.latitude,
      lng: _position!.longitude,
      radiusKm: _radius,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated
        ? authState.user.name.split(' ').first
        : 'there';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadNearby(),
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(userName),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addListing),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          AppStrings.addListing,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(String userName) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      titleSpacing: AppDimensions.md,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $userName 👋',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary),
                  const SizedBox(width: 2),
                  Text(
                    _position != null ? 'Near you' : 'Enable location',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md, AppDimensions.sm, AppDimensions.md, AppDimensions.sm,
      ),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.explore),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Text(
                AppStrings.searchHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        itemCount: AppConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
        itemBuilder: (context, i) {
          final cat = AppConstants.categories[i];
          final isSelected = cat == _selectedCategory;
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) {
              setState(() => _selectedCategory = cat);
              _loadNearby();
            },
            selectedColor: AppColors.primaryContainer,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildContent() {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        if (state is ListingLoading) {
          return const Padding(
            padding: EdgeInsets.only(top: 100),
            child: LoadingWidget(),
          );
        }
        if (state is ListingError) {
          return Padding(
            padding: const EdgeInsets.only(top: 80),
            child: AppErrorWidget(message: state.message, onRetry: _loadNearby),
          );
        }
        if (state is NearbyListingsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.listings.isNotEmpty) ...[
                _buildSectionHeader(context, AppStrings.nearby,
                    onSeeAll: () => context.push(AppRoutes.explore)),
                _buildHorizontalListings(state.listings),
              ],
              if (state.trending.isNotEmpty) ...[
                _buildSectionHeader(context, AppStrings.trending),
                _buildVerticalListings(state.trending),
              ],
              if (state.listings.isEmpty && state.trending.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: AppEmptyWidget(
                    message: AppStrings.noItemsFound,
                    icon: Icons.search_off_rounded,
                  ),
                ),
              const SizedBox(height: 100),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md, AppDimensions.lg, AppDimensions.md, AppDimensions.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      ),
    );
  }

  Widget _buildHorizontalListings(listings) {
    return SizedBox(
      height: AppDimensions.listingCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        itemCount: listings.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
        itemBuilder: (context, i) => SizedBox(
          width: AppDimensions.listingCardWidth,
          child: ListingCard(listing: listings[i]).animate().fadeIn(delay: (i * 50).ms),
        ),
      ),
    );
  }

  Widget _buildVerticalListings(listings) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      itemCount: listings.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sm),
      itemBuilder: (context, i) => ListingCardHorizontal(listing: listings[i]),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
