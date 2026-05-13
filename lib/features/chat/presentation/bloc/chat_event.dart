import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatLoadUserChats extends ChatEvent {
  final String userId;
  const ChatLoadUserChats(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ChatOpenOrCreate extends ChatEvent {
  final String currentUserId;
  final String otherUserId;
  final String? listingId;
  final String? listingTitle;
  final String? listingImageUrl;
  const ChatOpenOrCreate({
    required this.currentUserId,
    required this.otherUserId,
    this.listingId,
    this.listingTitle,
    this.listingImageUrl,
  });
  @override
  List<Object?> get props => [currentUserId, otherUserId, listingId];
}

class ChatLoadMessages extends ChatEvent {
  final String chatId;
  const ChatLoadMessages(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

class ChatSendMessage extends ChatEvent {
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  const ChatSendMessage({
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
  });
  @override
  List<Object?> get props => [chatId, content];
}

class ChatSendImage extends ChatEvent {
  final String chatId;
  final String senderId;
  final String senderName;
  final File image;
  const ChatSendImage({
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.image,
  });
}

class ChatMarkAsRead extends ChatEvent {
  final String chatId;
  final String userId;
  const ChatMarkAsRead({required this.chatId, required this.userId});
  @override
  List<Object?> get props => [chatId, userId];
}
