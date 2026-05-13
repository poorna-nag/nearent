import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_entity.dart';

abstract class ListingEvent extends Equatable {
  const ListingEvent();
  @override
  List<Object?> get props => [];
}

class ListingLoadNearby extends ListingEvent {
  final double lat;
  final double lng;
  final double radiusKm;
  final String? category;
  final String? listingType;
  const ListingLoadNearby({
    required this.lat,
    required this.lng,
    required this.radiusKm,
    this.category,
    this.listingType,
  });
  @override
  List<Object?> get props => [lat, lng, radiusKm, category, listingType];
}

class ListingLoadTrending extends ListingEvent {
  const ListingLoadTrending();
}

class ListingSearch extends ListingEvent {
  final String query;
  final String? category;
  const ListingSearch({required this.query, this.category});
  @override
  List<Object?> get props => [query, category];
}

class ListingLoadById extends ListingEvent {
  final String id;
  const ListingLoadById(this.id);
  @override
  List<Object?> get props => [id];
}

class ListingCreate extends ListingEvent {
  final ListingEntity listing;
  final List<File> images;
  const ListingCreate({required this.listing, required this.images});
  @override
  List<Object?> get props => [listing];
}

class ListingUpdate extends ListingEvent {
  final ListingEntity listing;
  final List<File>? newImages;
  const ListingUpdate({required this.listing, this.newImages});
  @override
  List<Object?> get props => [listing];
}

class ListingDelete extends ListingEvent {
  final String id;
  const ListingDelete(this.id);
  @override
  List<Object?> get props => [id];
}

class ListingToggleFavorite extends ListingEvent {
  final String listingId;
  final String userId;
  const ListingToggleFavorite({required this.listingId, required this.userId});
  @override
  List<Object?> get props => [listingId, userId];
}

class ListingLoadFavorites extends ListingEvent {
  final String userId;
  const ListingLoadFavorites(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ListingLoadByUser extends ListingEvent {
  final String userId;
  const ListingLoadByUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ListingReport extends ListingEvent {
  final String listingId;
  final String reason;
  final String reporterId;
  const ListingReport({required this.listingId, required this.reason, required this.reporterId});
  @override
  List<Object?> get props => [listingId, reason, reporterId];
}
