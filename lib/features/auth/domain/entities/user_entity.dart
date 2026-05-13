import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? bio;
  final String? city;
  final String? area;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int ratingsCount;
  final int listingsCount;
  final double trustScore;
  final String role;
  final bool isVerified;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime? lastSeen;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.bio,
    this.city,
    this.area,
    this.latitude,
    this.longitude,
    this.rating = 0.0,
    this.ratingsCount = 0,
    this.listingsCount = 0,
    this.trustScore = 0.0,
    this.role = 'user',
    this.isVerified = false,
    this.isBlocked = false,
    required this.createdAt,
    this.lastSeen,
  });

  @override
  List<Object?> get props => [id, email];
}
