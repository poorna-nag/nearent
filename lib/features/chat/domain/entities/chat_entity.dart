import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantImages;
  final String? listingId;
  final String? listingTitle;
  final String? listingImageUrl;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount;

  const ChatEntity({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantImages,
    this.listingId,
    this.listingTitle,
    this.listingImageUrl,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [id];
}

class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final String type; // text, image
  final bool isRead;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = 'text',
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id];
}
