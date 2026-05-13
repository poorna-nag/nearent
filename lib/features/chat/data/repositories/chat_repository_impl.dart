import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid;

  const ChatRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    Uuid uuid = const Uuid(),
  })  : _firestore = firestore,
        _storage = storage,
        _uuid = uuid;

  @override
  Stream<List<ChatEntity>> getUserChats(String userId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<MessageEntity>> getChatMessages(String chatId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.chatMessageLimit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }

  @override
  Future<ChatEntity> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    String? listingId,
    String? listingTitle,
    String? listingImageUrl,
  }) async {
    // Check for existing chat between these two users for this listing
    final query = await _firestore
        .collection(AppConstants.chatsCollection)
        .where('participantIds', arrayContains: currentUserId)
        .get();

    for (final doc in query.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participantIds'] ?? []);
      if (participants.contains(otherUserId)) {
        if (listingId == null || data['listingId'] == listingId) {
          return ChatModel.fromFirestore(doc);
        }
      }
    }

    // Get user info for both participants
    final currentUserDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(currentUserId)
        .get();
    final otherUserDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(otherUserId)
        .get();

    final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
    final otherUserData = otherUserDoc.data() as Map<String, dynamic>;

    final chatModel = ChatModel(
      id: _uuid.v4(),
      participantIds: [currentUserId, otherUserId],
      participantNames: {
        currentUserId: currentUserData['name'] ?? '',
        otherUserId: otherUserData['name'] ?? '',
      },
      participantImages: {
        currentUserId: currentUserData['profileImageUrl'],
        otherUserId: otherUserData['profileImageUrl'],
      },
      listingId: listingId,
      listingTitle: listingTitle,
      listingImageUrl: listingImageUrl,
      lastMessage: '',
      lastMessageSenderId: currentUserId,
      lastMessageTime: DateTime.now(),
      unreadCount: {currentUserId: 0, otherUserId: 0},
    );

    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatModel.id)
        .set(chatModel.toFirestore());

    return chatModel;
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text',
  }) async {
    try {
      final messageId = _uuid.v4();
      final message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();

      batch.set(
        _firestore
            .collection(AppConstants.chatsCollection)
            .doc(chatId)
            .collection(AppConstants.messagesCollection)
            .doc(messageId),
        message.toFirestore(),
      );

      // Get chat to increment unread for other participant
      final chatDoc = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .get();
      final chatData = chatDoc.data() as Map<String, dynamic>;
      final participants = List<String>.from(chatData['participantIds'] ?? []);
      final otherId = participants.firstWhere(
        (id) => id != senderId,
        orElse: () => '',
      );

      final unreadUpdate = <String, dynamic>{
        'lastMessage': type == 'image' ? '📷 Photo' : content,
        'lastMessageSenderId': senderId,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      };
      if (otherId.isNotEmpty) {
        unreadUpdate['unreadCount.$otherId'] = FieldValue.increment(1);
      }

      batch.update(
        _firestore.collection(AppConstants.chatsCollection).doc(chatId),
        unreadUpdate,
      );

      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required File image,
  }) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage
        .ref()
        .child(AppConstants.chatImagesPath)
        .child(chatId)
        .child(fileName);
    await ref.putFile(image);
    final imageUrl = await ref.getDownloadURL();

    await sendMessage(
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: imageUrl,
      type: 'image',
    );
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    await _firestore.collection(AppConstants.chatsCollection).doc(chatId).update({
      'unreadCount.$userId': 0,
    });

    final unreadMessages = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Stream<bool> getUserOnlineStatus(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => (doc.data()?['isOnline'] as bool?) ?? false);
  }
}
