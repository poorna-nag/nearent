import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_entity.dart';

abstract class ListingState extends Equatable {
  const ListingState();
  @override
  List<Object?> get props => [];
}

class ListingInitial extends ListingState {
  const ListingInitial();
}

class ListingLoading extends ListingState {
  const ListingLoading();
}

class NearbyListingsLoaded extends ListingState {
  final List<ListingEntity> listings;
  final List<ListingEntity> trending;
  const NearbyListingsLoaded({required this.listings, required this.trending});
  @override
  List<Object?> get props => [listings, trending];
}

class SearchResultsLoaded extends ListingState {
  final List<ListingEntity> results;
  final String query;
  const SearchResultsLoaded({required this.results, required this.query});
  @override
  List<Object?> get props => [results, query];
}

class ListingDetailLoaded extends ListingState {
  final ListingEntity listing;
  final bool isFavorite;
  const ListingDetailLoaded({required this.listing, required this.isFavorite});
  @override
  List<Object?> get props => [listing, isFavorite];
}

class UserListingsLoaded extends ListingState {
  final List<ListingEntity> listings;
  const UserListingsLoaded(this.listings);
  @override
  List<Object?> get props => [listings];
}

class FavoriteListingsLoaded extends ListingState {
  final List<ListingEntity> listings;
  const FavoriteListingsLoaded(this.listings);
  @override
  List<Object?> get props => [listings];
}

class ListingCreated extends ListingState {
  final String listingId;
  const ListingCreated(this.listingId);
  @override
  List<Object?> get props => [listingId];
}

class ListingUpdated extends ListingState {
  const ListingUpdated();
}

class ListingDeleted extends ListingState {
  const ListingDeleted();
}

class ListingError extends ListingState {
  final String message;
  const ListingError(this.message);
  @override
  List<Object?> get props => [message];
}
