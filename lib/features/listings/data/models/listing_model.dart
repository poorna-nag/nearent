import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/listing_entity.dart';

class ListingModel extends ListingEntity {
  const ListingModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrls,
    super.sellPrice,
    super.rentPricePerDay,
    super.isForExchange,
    required super.category,
    required super.condition,
    required super.listingType,
    super.isAvailable,
    required super.sellerId,
    required super.sellerName,
    super.sellerImageUrl,
    super.sellerRating,
    required super.latitude,
    required super.longitude,
    super.city,
    super.area,
    super.distanceKm,
    super.viewCount,
    super.favoriteCount,
    required super.createdAt,
    required super.updatedAt,
    super.isReported,
  });

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      sellPrice: (data['sellPrice'] as num?)?.toDouble(),
      rentPricePerDay: (data['rentPricePerDay'] as num?)?.toDouble(),
      isForExchange: data['isForExchange'] ?? false,
      category: data['category'] ?? 'Others',
      condition: data['condition'] ?? 'Good',
      listingType: data['listingType'] ?? 'sell',
      isAvailable: data['isAvailable'] ?? true,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerImageUrl: data['sellerImageUrl'],
      sellerRating: (data['sellerRating'] as num?)?.toDouble() ?? 0.0,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      city: data['city'],
      area: data['area'],
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      favoriteCount: (data['favoriteCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isReported: data['isReported'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'sellPrice': sellPrice,
      'rentPricePerDay': rentPricePerDay,
      'isForExchange': isForExchange,
      'category': category,
      'condition': condition,
      'listingType': listingType,
      'isAvailable': isAvailable,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerImageUrl': sellerImageUrl,
      'sellerRating': sellerRating,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'area': area,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isReported': isReported,
    };
  }
}
