import 'dart:io';
import '../entities/listing_entity.dart';

abstract class ListingRepository {
  Future<List<ListingEntity>> getNearbyListings({
    required double lat,
    required double lng,
    required double radiusKm,
    String? category,
    String? listingType,
  });

  Future<List<ListingEntity>> getListingsByUser(String userId);
  Future<List<ListingEntity>> getTrendingListings();
  Future<List<ListingEntity>> searchListings(String query, {String? category});
  Future<ListingEntity> getListingById(String id);
  Future<String> createListing(ListingEntity listing, List<File> images);
  Future<void> updateListing(ListingEntity listing, {List<File>? newImages});
  Future<void> deleteListing(String id);
  Future<void> incrementViewCount(String id);
  Future<void> reportListing(String id, String reason, String reporterId);
  Future<List<ListingEntity>> getFavoriteListings(String userId);
  Future<void> toggleFavorite(String listingId, String userId);
  Future<bool> isFavorite(String listingId, String userId);
}
