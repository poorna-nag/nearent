import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class UserChatsLoaded extends ChatState {
  final List<ChatEntity> chats;
  const UserChatsLoaded(this.chats);
  @override
  List<Object?> get props => [chats];
}

class ChatOpened extends ChatState {
  final ChatEntity chat;
  const ChatOpened(this.chat);
  @override
  List<Object?> get props => [chat];
}

class ChatMessagesLoaded extends ChatState {
  final List<MessageEntity> messages;
  final ChatEntity chat;
  const ChatMessagesLoaded({required this.messages, required this.chat});
  @override
  List<Object?> get props => [messages, chat];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}
