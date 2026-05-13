import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _chatsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatBloc({required ChatRepository repository})
      : _repository = repository,
        super(const ChatInitial()) {
    on<ChatLoadUserChats>(_onLoadUserChats);
    on<ChatOpenOrCreate>(_onOpenOrCreate);
    on<ChatLoadMessages>(_onLoadMessages);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatSendImage>(_onSendImage);
    on<ChatMarkAsRead>(_onMarkAsRead);
  }

  void _onLoadUserChats(ChatLoadUserChats event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    await emit.forEach(
      _repository.getUserChats(event.userId),
      onData: (chats) => UserChatsLoaded(chats),
      onError: (e, _) => ChatError(e.toString()),
    );
  }

  Future<void> _onOpenOrCreate(ChatOpenOrCreate event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    try {
      final chat = await _repository.getOrCreateChat(
        currentUserId: event.currentUserId,
        otherUserId: event.otherUserId,
        listingId: event.listingId,
        listingTitle: event.listingTitle,
        listingImageUrl: event.listingImageUrl,
      );
      emit(ChatOpened(chat));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onLoadMessages(ChatLoadMessages event, Emitter<ChatState> emit) async {
    final currentState = state;
    ChatEntity? chat;
    if (currentState is ChatOpened) chat = currentState.chat;
    if (currentState is ChatMessagesLoaded) chat = currentState.chat;
    if (chat == null) return;

    await emit.forEach(
      _repository.getChatMessages(event.chatId),
      onData: (messages) => ChatMessagesLoaded(messages: messages, chat: chat!),
      onError: (e, _) => ChatError(e.toString()),
    );
  }

  Future<void> _onSendMessage(ChatSendMessage event, Emitter<ChatState> emit) async {
    try {
      await _repository.sendMessage(
        chatId: event.chatId,
        senderId: event.senderId,
        senderName: event.senderName,
        content: event.content,
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendImage(ChatSendImage event, Emitter<ChatState> emit) async {
    try {
      await _repository.sendImageMessage(
        chatId: event.chatId,
        senderId: event.senderId,
        senderName: event.senderName,
        image: event.image,
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(ChatMarkAsRead event, Emitter<ChatState> emit) async {
    await _repository.markMessagesAsRead(event.chatId, event.userId);
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
