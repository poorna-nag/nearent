import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/listing_repository.dart';
import 'listing_event.dart';
import 'listing_state.dart';

class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final ListingRepository _repository;

  ListingBloc({required ListingRepository repository})
      : _repository = repository,
        super(const ListingInitial()) {
    on<ListingLoadNearby>(_onLoadNearby);
    on<ListingLoadTrending>(_onLoadTrending);
    on<ListingSearch>(_onSearch);
    on<ListingLoadById>(_onLoadById);
    on<ListingCreate>(_onCreate);
    on<ListingUpdate>(_onUpdate);
    on<ListingDelete>(_onDelete);
    on<ListingToggleFavorite>(_onToggleFavorite);
    on<ListingLoadFavorites>(_onLoadFavorites);
    on<ListingLoadByUser>(_onLoadByUser);
    on<ListingReport>(_onReport);
  }

  Future<void> _onLoadNearby(ListingLoadNearby event, Emitter<ListingState> emit) async {
    emit(const ListingLoading());
    try {
      final results = await Future.wait([
        _repository.getNearbyListings(
          lat: event.lat,
          lng: event.lng,
          radiusKm: event.radiusKm,
          category: event.category,
          listingType: event.listingType,
        ),
        _repository.getTrendingListings(),
      ]);
      emit(NearbyListingsLoaded(
        listings: results[0],
        trending: results[1],
      ));
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onLoadTrending(ListingLoadTrending event, Emitter<ListingState> emit) async {
    emit(const ListingLoading());
    try {
      final listings = await _repository.getTrendingListings();
      emit(NearbyListingsLoaded(listings: listings, trending: listings));
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onSearch(ListingSearch event, Emitter<ListingState> emit) async {
    emit(const ListingLoading());
    try {
      final results = await _repository.searchListings(event.query, category: event.category);
      emit(SearchResultsLoaded(results: results, query: event.query));
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onLoadById(ListingLoadById event, Emitter<ListingState> emit) async {
    emit(const ListingLoading());
    try {
      final listing = await _repository.getListingById(event.id);
      await _repository.incrementViewCount(event.id);
      emit(ListingDetailLoaded(listing: listing, isFavorite: false));
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onCreate(ListingCreate event, Emitter<ListingState> emit) async {
    emit(const ListingLoading());
    try {
      final id = await _repository.createListing(event.listing, event.images);
      emit(ListingCreated(id));
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onUpdate(ListingUpdate event, Emitter<ListingState> emit) async {
    emit(const ListingLoading());
    try {
      await _repository.updateListing(event.listing, newImages: event.newImages);
      emit(const ListingUpdated());
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onDelete(ListingDelete event, Emitter<ListingState> emit) async {
    emit(const ListingLoading());
    try {
      await _repository.deleteListing(event.id);
      emit(const ListingDeleted());
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(ListingToggleFavorite event, Emitter<ListingState> emit) async {
    try {
      await _repository.toggleFavorite(event.listingId, event.userId);
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onLoadFavorites(ListingLoadFavorites event, Emitter<ListingState> emit) async {
    emit(const ListingLoading());
    try {
      final listings = await _repository.getFavoriteListings(event.userId);
      emit(FavoriteListingsLoaded(listings));
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onLoadByUser(ListingLoadByUser event, Emitter<ListingState> emit) async {
    emit(const ListingLoading());
    try {
      final listings = await _repository.getListingsByUser(event.userId);
      emit(UserListingsLoaded(listings));
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onReport(ListingReport event, Emitter<ListingState> emit) async {
    try {
      await _repository.reportListing(event.listingId, event.reason, event.reporterId);
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }
}
