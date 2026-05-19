import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../listings/presentation/bloc/listing_bloc.dart';
import '../../../listings/presentation/bloc/listing_event.dart';
import '../../../listings/presentation/bloc/listing_state.dart';
import '../../../listings/presentation/widgets/listing_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ListingBloc>().add(ListingLoadByUser(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'My Listings'), Tab(text: 'Saved')],
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMyListings(), _buildSavedListings()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addListing),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildMyListings() {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        if (state is UserListingsLoaded) {
          if (state.listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sell_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: AppDimensions.md),
                  const Text('No listings yet',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: AppDimensions.md),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.addListing),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Post your first item'),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: AppDimensions.sm,
              mainAxisSpacing: AppDimensions.sm,
            ),
            itemCount: state.listings.length,
            itemBuilder: (context, i) {
              final listing = state.listings[i];
              return Stack(
                children: [
                  ListingCard(listing: listing).animate().fadeIn(delay: (i * 50).ms),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: const Icon(Icons.more_vert_rounded,
                            color: Colors.white, size: 18),
                      ),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          child: const Row(children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ]),
                          onTap: () => context.push(AppRoutes.editListing(listing.id)),
                        ),
                        PopupMenuItem(
                          child: const Row(children: [
                            Icon(Icons.delete_outline_rounded, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
                          ]),
                          onTap: () => _confirmDelete(listing.id),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSavedListings() {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        if (state is FavoriteListingsLoaded) {
          if (state.listings.isEmpty) {
            return const AppEmptyWidget(
              message: AppStrings.noFavorites,
              icon: Icons.favorite_outline_rounded,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: AppDimensions.sm,
              mainAxisSpacing: AppDimensions.sm,
            ),
            itemCount: state.listings.length,
            itemBuilder: (context, i) => ListingCard(listing: state.listings[i])
                .animate()
                .fadeIn(delay: (i * 50).ms),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _confirmDelete(String listingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ListingBloc>().add(ListingDelete(listingId));
              _loadData();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
