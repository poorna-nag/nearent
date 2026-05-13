import 'dart:io';
import '../entities/chat_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatEntity>> getUserChats(String userId);
  Stream<List<MessageEntity>> getChatMessages(String chatId);
  Future<ChatEntity> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    String? listingId,
    String? listingTitle,
    String? listingImageUrl,
  });
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text',
  });
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required File image,
  });
  Future<void> markMessagesAsRead(String chatId, String userId);
  Future<void> updateUserOnlineStatus(String userId, bool isOnline);
  Stream<bool> getUserOnlineStatus(String userId);
}
