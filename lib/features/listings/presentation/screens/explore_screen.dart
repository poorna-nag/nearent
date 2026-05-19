import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';
import '../widgets/listing_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    context.read<ListingBloc>().add(const ListingLoadTrending());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        titleSpacing: AppDimensions.md,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryBar(),
          _buildTypeFilters(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: AppStrings.searchHint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppColors.border.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                  context.read<ListingBloc>().add(const ListingLoadTrending());
                },
              )
            : null,
      ),
      onChanged: (query) {
        setState(() {});
        if (query.trim().length >= 2) {
          context.read<ListingBloc>().add(ListingSearch(
            query: query.trim(),
            category: _selectedCategory == 'All' ? null : _selectedCategory,
          ));
        }
      },
      onSubmitted: (query) {
        if (query.trim().isNotEmpty) {
          context.read<ListingBloc>().add(ListingSearch(
            query: query.trim(),
            category: _selectedCategory == 'All' ? null : _selectedCategory,
          ));
        }
      },
    );
  }

  Widget _buildCategoryBar() {
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
              _search();
            },
            selectedColor: AppColors.primaryContainer,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeFilters() {
    final types = [
      ('All', null),
      ('For Sale', 'sell'),
      ('For Rent', 'rent'),
      ('Exchange', 'exchange'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md, vertical: AppDimensions.xs,
      ),
      child: Row(
        children: types.map((t) {
          final isSelected = _selectedType == t.$2;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.sm),
            child: FilterChip(
              label: Text(t.$1),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedType = t.$2);
                _search();
              },
              selectedColor: AppColors.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : null,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResults() {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        if (state is ListingLoading) return const LoadingWidget();
        if (state is ListingError) {
          return AppErrorWidget(message: state.message, onRetry: _search);
        }

        List listings = [];
        if (state is SearchResultsLoaded) listings = state.results;
        if (state is NearbyListingsLoaded) listings = state.listings;

        if (listings.isEmpty) {
          return const AppEmptyWidget(
            message: AppStrings.noItemsFound,
            icon: Icons.search_off_rounded,
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
          itemCount: listings.length,
          itemBuilder: (context, i) =>
              ListingCard(listing: listings[i]).animate().fadeIn(delay: (i * 30).ms),
        );
      },
    );
  }

  void _search() {
    final q = _searchController.text.trim();
    if (q.isNotEmpty) {
      context.read<ListingBloc>().add(ListingSearch(
        query: q,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
      ));
    } else {
      context.read<ListingBloc>().add(const ListingLoadTrending());
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppDimensions.lg),
            const Text('Radius, price range, and condition filters — coming soon.'),
            const SizedBox(height: AppDimensions.xl),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
