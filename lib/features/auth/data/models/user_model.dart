import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,
    super.profileImageUrl,
    super.bio,
    super.city,
    super.area,
    super.latitude,
    super.longitude,
    super.rating,
    super.ratingsCount,
    super.listingsCount,
    super.trustScore,
    super.role,
    super.isVerified,
    super.isBlocked,
    required super.createdAt,
    super.lastSeen,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      bio: data['bio'],
      city: data['city'],
      area: data['area'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: (data['ratingsCount'] as num?)?.toInt() ?? 0,
      listingsCount: (data['listingsCount'] as num?)?.toInt() ?? 0,
      trustScore: (data['trustScore'] as num?)?.toDouble() ?? 0.0,
      role: data['role'] ?? 'user',
      isVerified: data['isVerified'] ?? false,
      isBlocked: data['isBlocked'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'city': city,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'ratingsCount': ratingsCount,
      'listingsCount': listingsCount,
      'trustScore': trustScore,
      'role': role,
      'isVerified': isVerified,
      'isBlocked': isBlocked,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      profileImageUrl: entity.profileImageUrl,
      bio: entity.bio,
      city: entity.city,
      area: entity.area,
      latitude: entity.latitude,
      longitude: entity.longitude,
      rating: entity.rating,
      ratingsCount: entity.ratingsCount,
      listingsCount: entity.listingsCount,
      trustScore: entity.trustScore,
      role: entity.role,
      isVerified: entity.isVerified,
      isBlocked: entity.isBlocked,
      createdAt: entity.createdAt,
      lastSeen: entity.lastSeen,
    );
  }
}
