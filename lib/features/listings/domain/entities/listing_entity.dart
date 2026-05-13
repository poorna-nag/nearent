import 'package:equatable/equatable.dart';

class ListingEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final double? sellPrice;
  final double? rentPricePerDay;
  final bool isForExchange;
  final String category;
  final String condition;
  final String listingType; // sell, rent, exchange
  final bool isAvailable;
  final String sellerId;
  final String sellerName;
  final String? sellerImageUrl;
  final double sellerRating;
  final double latitude;
  final double longitude;
  final String? city;
  final String? area;
  final double? distanceKm;
  final int viewCount;
  final int favoriteCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isReported;

  const ListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    this.sellPrice,
    this.rentPricePerDay,
    this.isForExchange = false,
    required this.category,
    required this.condition,
    required this.listingType,
    this.isAvailable = true,
    required this.sellerId,
    required this.sellerName,
    this.sellerImageUrl,
    this.sellerRating = 0.0,
    required this.latitude,
    required this.longitude,
    this.city,
    this.area,
    this.distanceKm,
    this.viewCount = 0,
    this.favoriteCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isReported = false,
  });

  ListingEntity copyWith({double? distanceKm}) {
    return ListingEntity(
      id: id,
      title: title,
      description: description,
      imageUrls: imageUrls,
      sellPrice: sellPrice,
      rentPricePerDay: rentPricePerDay,
      isForExchange: isForExchange,
      category: category,
      condition: condition,
      listingType: listingType,
      isAvailable: isAvailable,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerImageUrl: sellerImageUrl,
      sellerRating: sellerRating,
      latitude: latitude,
      longitude: longitude,
      city: city,
      area: area,
      distanceKm: distanceKm ?? this.distanceKm,
      viewCount: viewCount,
      favoriteCount: favoriteCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isReported: isReported,
    );
  }

  @override
  List<Object?> get props => [id];
}
