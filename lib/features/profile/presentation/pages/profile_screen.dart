import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../listings/presentation/bloc/listing_bloc.dart';
import '../../../listings/presentation/bloc/listing_event.dart';
import '../../../listings/presentation/bloc/listing_state.dart';
import '../../../listings/presentation/widgets/listing_card.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final targetId = widget.userId ??
        (authState is AuthAuthenticated ? authState.user.id : null);
    if (targetId != null) {
      context.read<ListingBloc>().add(ListingLoadByUser(targetId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isOwnProfile = widget.userId == null ||
        (authState is AuthAuthenticated && authState.user.id == widget.userId);

    if (authState is! AuthAuthenticated && widget.userId == null) {
      return _buildSignInPrompt(context);
    }

    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildProfileAppBar(context, user, isOwnProfile),
          SliverToBoxAdapter(child: _buildStats(context, user)),
          SliverToBoxAdapter(child: _buildBio(context, user)),
          if (isOwnProfile) SliverToBoxAdapter(child: _buildMenuItems(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.md, AppDimensions.lg, AppDimensions.md, AppDimensions.sm,
              ),
              child: Text(
                AppStrings.myListings,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _buildUserListings(),
        ],
      ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline_rounded, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppDimensions.lg),
            Text('Sign in to view your profile',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text(AppStrings.signIn),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildProfileAppBar(BuildContext context, UserEntity? user, bool isOwnProfile) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      actions: [
        if (isOwnProfile)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        if (isOwnProfile)
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () => context.read<AuthBloc>().add(const AuthSignOut()),
                child: const Row(children: [
                  Icon(Icons.logout_rounded, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(AppStrings.signOut),
                ]),
              ),
            ],
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppDimensions.lg),
                CircleAvatar(
                  radius: AppDimensions.avatarXl / 2,
                  backgroundColor: Colors.white24,
                  backgroundImage: user?.profileImageUrl != null
                      ? CachedNetworkImageProvider(user!.profileImageUrl!)
                      : null,
                  child: user?.profileImageUrl == null
                      ? Text(
                          AppHelpers.getInitials(user?.name ?? '?'),
                          style: const TextStyle(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  user?.name ?? '',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                if (user?.city != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: Colors.white70),
                      Text(user!.city!,
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, UserEntity? user) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _statItem(context, '${user?.listingsCount ?? 0}', 'Listings'),
          _divider(),
          _statItem(context, user?.rating.toStringAsFixed(1) ?? '0.0', 'Rating'),
          _divider(),
          _statItem(context, '${user?.trustScore.toStringAsFixed(0) ?? '0'}%', 'Trust'),
          _divider(),
          _statItem(
            context,
            user?.createdAt != null ? AppHelpers.formatDate(user!.createdAt) : '–',
            'Joined',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _statItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 32, width: 1, color: AppColors.divider);

  Widget _buildBio(BuildContext context, UserEntity? user) {
    if (user?.bio == null || user!.bio!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Text(
        user.bio!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final items = [
      (Icons.favorite_outline_rounded, AppStrings.favorites, AppRoutes.favorites),
      (Icons.notifications_outlined, AppStrings.notifications, AppRoutes.notifications),
      (Icons.settings_outlined, AppStrings.settings, AppRoutes.settings),
      (Icons.help_outline_rounded, AppStrings.helpCenter, AppRoutes.help),
      (Icons.info_outline_rounded, AppStrings.about, AppRoutes.about),
    ];
    return Column(
      children: [
        const Divider(indent: AppDimensions.md, endIndent: AppDimensions.md),
        ...items.map((item) => ListTile(
          leading: Icon(item.$1, color: AppColors.textSecondary),
          title: Text(item.$2),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          onTap: () => context.push(item.$3),
        )),
        const Divider(indent: AppDimensions.md, endIndent: AppDimensions.md),
      ],
    );
  }

  Widget _buildUserListings() {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        if (state is UserListingsLoaded && state.listings.isNotEmpty) {
          return SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.md),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => ListingCard(listing: state.listings[i])
                    .animate()
                    .fadeIn(delay: (i * 50).ms),
                childCount: state.listings.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: AppDimensions.sm,
                mainAxisSpacing: AppDimensions.sm,
              ),
            ),
          );
        }
        if (state is UserListingsLoaded && state.listings.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.xl),
              child: AppEmptyWidget(message: 'No listings yet', icon: Icons.sell_outlined),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
