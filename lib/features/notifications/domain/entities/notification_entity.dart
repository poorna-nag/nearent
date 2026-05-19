import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // listing, chat, system
  final String? listingId;
  final String? senderId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.listingId,
    this.senderId,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id];
}
