import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/listing_repository.dart';
import '../models/listing_model.dart';

class ListingRepositoryImpl implements ListingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid;

  const ListingRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    Uuid uuid = const Uuid(),
  })  : _firestore = firestore,
        _storage = storage,
        _uuid = uuid;

  CollectionReference get _listingsRef =>
      _firestore.collection(AppConstants.listingsCollection);

  @override
  Future<List<ListingEntity>> getNearbyListings({
    required double lat,
    required double lng,
    required double radiusKm,
    String? category,
    String? listingType,
  }) async {
    try {
      const kmPerDegree = 111.0;
      final latDelta = radiusKm / kmPerDegree;
      final lngDelta = radiusKm / kmPerDegree;

      Query query = _listingsRef
          .where('isAvailable', isEqualTo: true)
          .where('isReported', isEqualTo: false)
          .where('latitude', isGreaterThanOrEqualTo: lat - latDelta)
          .where('latitude', isLessThanOrEqualTo: lat + latDelta)
          .orderBy('latitude')
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.nearbyListingsLimit);

      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      if (listingType != null) {
        query = query.where('listingType', isEqualTo: listingType);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .where((listing) {
            final lngDiff = (listing.longitude - lng).abs();
            return lngDiff <= lngDelta;
          })
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ListingEntity>> getListingsByUser(String userId) async {
    final snapshot = await _listingsRef
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<ListingEntity>> getTrendingListings() async {
    final snapshot = await _listingsRef
        .where('isAvailable', isEqualTo: true)
        .orderBy('viewCount', descending: true)
        .limit(AppConstants.paginationLimit)
        .get();
    return snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<ListingEntity>> searchListings(String query, {String? category}) async {
    Query firestoreQuery = _listingsRef
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (category != null && category != 'All') {
      firestoreQuery = firestoreQuery.where('category', isEqualTo: category);
    }

    final snapshot = await firestoreQuery.limit(50).get();
    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => ListingModel.fromFirestore(doc))
        .where((listing) =>
            listing.title.toLowerCase().contains(lowerQuery) ||
            listing.description.toLowerCase().contains(lowerQuery) ||
            listing.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<ListingEntity> getListingById(String id) async {
    final doc = await _listingsRef.doc(id).get();
    if (!doc.exists) throw const NotFoundException('Listing not found');
    return ListingModel.fromFirestore(doc);
  }

  @override
  Future<String> createListing(ListingEntity listing, List<File> images) async {
    try {
      final imageUrls = await _uploadImages(images, listing.sellerId);
      final id = _uuid.v4();
      final model = ListingModel(
        id: id,
        title: listing.title,
        description: listing.description,
        imageUrls: imageUrls,
        sellPrice: listing.sellPrice,
        rentPricePerDay: listing.rentPricePerDay,
        isForExchange: listing.isForExchange,
        category: listing.category,
        condition: listing.condition,
        listingType: listing.listingType,
        isAvailable: true,
        sellerId: listing.sellerId,
        sellerName: listing.sellerName,
        sellerImageUrl: listing.sellerImageUrl,
        sellerRating: listing.sellerRating,
        latitude: listing.latitude,
        longitude: listing.longitude,
        city: listing.city,
        area: listing.area,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _listingsRef.doc(id).set(model.toFirestore());

      // Increment user listings count
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(listing.sellerId)
          .update({'listingsCount': FieldValue.increment(1)});

      return id;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateListing(ListingEntity listing, {List<File>? newImages}) async {
    try {
      List<String> imageUrls = listing.imageUrls;
      if (newImages != null && newImages.isNotEmpty) {
        final uploaded = await _uploadImages(newImages, listing.sellerId);
        imageUrls = [...listing.imageUrls, ...uploaded];
      }

      await _listingsRef.doc(listing.id).update({
        'title': listing.title,
        'description': listing.description,
        'imageUrls': imageUrls,
        'sellPrice': listing.sellPrice,
        'rentPricePerDay': listing.rentPricePerDay,
        'isForExchange': listing.isForExchange,
        'category': listing.category,
        'condition': listing.condition,
        'listingType': listing.listingType,
        'isAvailable': listing.isAvailable,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    final doc = await _listingsRef.doc(id).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final sellerId = data['sellerId'] as String?;
      await _listingsRef.doc(id).delete();
      if (sellerId != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(sellerId)
            .update({'listingsCount': FieldValue.increment(-1)});
      }
    }
  }

  @override
  Future<void> incrementViewCount(String id) async {
    await _listingsRef.doc(id).update({'viewCount': FieldValue.increment(1)});
  }

  @override
  Future<void> reportListing(String id, String reason, String reporterId) async {
    await _firestore.collection(AppConstants.reportsCollection).add({
      'listingId': id,
      'reason': reason,
      'reporterId': reporterId,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<List<ListingEntity>> getFavoriteListings(String userId) async {
    final favSnapshot = await _firestore
        .collection(AppConstants.favoritesCollection)
        .where('userId', isEqualTo: userId)
        .get();

    if (favSnapshot.docs.isEmpty) return [];

    final listingIds = favSnapshot.docs
        .map((doc) => doc.data()['listingId'] as String)
        .toList();

    final futures = listingIds
        .map((id) => _listingsRef.doc(id).get())
        .toList();
    final docs = await Future.wait(futures);
    return docs
        .where((doc) => doc.exists)
        .map((doc) => ListingModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> toggleFavorite(String listingId, String userId) async {
    final querySnapshot = await _firestore
        .collection(AppConstants.favoritesCollection)
        .where('userId', isEqualTo: userId)
        .where('listingId', isEqualTo: listingId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      await _firestore.collection(AppConstants.favoritesCollection).add({
        'userId': userId,
        'listingId': listingId,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      await _listingsRef.doc(listingId).update({
        'favoriteCount': FieldValue.increment(1),
      });
    } else {
      await querySnapshot.docs.first.reference.delete();
      await _listingsRef.doc(listingId).update({
        'favoriteCount': FieldValue.increment(-1),
      });
    }
  }

  @override
  Future<bool> isFavorite(String listingId, String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.favoritesCollection)
        .where('userId', isEqualTo: userId)
        .where('listingId', isEqualTo: listingId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<List<String>> _uploadImages(List<File> images, String userId) async {
    final futures = images.map((image) async {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage
          .ref()
          .child(AppConstants.listingImagesPath)
          .child(userId)
          .child(fileName);
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final snapshot = await ref.putFile(image, metadata);
      return snapshot.ref.getDownloadURL();
    });
    return Future.wait(futures);
  }
}
