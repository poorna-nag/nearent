import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../domain/entities/chat_entity.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String? chatId;
  final String? listingId;
  final String? listingTitle;
  final String? listingImageUrl;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    this.chatId,
    this.listingId,
    this.listingTitle,
    this.listingImageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  ChatEntity? _chat;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    if (widget.chatId != null) {
      _chatId = widget.chatId;
      context.read<ChatBloc>().add(ChatLoadMessages(widget.chatId!));
    } else {
      context.read<ChatBloc>().add(ChatOpenOrCreate(
        currentUserId: widget.currentUserId,
        otherUserId: widget.otherUserId,
        listingId: widget.listingId,
        listingTitle: widget.listingTitle,
        listingImageUrl: widget.listingImageUrl,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatOpened) {
          _chat = state.chat;
          _chatId = state.chat.id;
          context.read<ChatBloc>().add(ChatLoadMessages(state.chat.id));
          context.read<ChatBloc>().add(ChatMarkAsRead(
            chatId: state.chat.id,
            userId: widget.currentUserId,
          ));
        }
        if (state is ChatMessagesLoaded) {
          _chat = state.chat;
          _chatId = state.chat.id;
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        final otherName = _chat?.participantNames[widget.otherUserId] ?? 'User';
        final otherImage = _chat?.participantImages[widget.otherUserId];

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.pop(),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: otherImage != null
                      ? CachedNetworkImageProvider(otherImage)
                      : null,
                  child: otherImage == null
                      ? Text(
                          AppHelpers.getInitials(otherName),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppDimensions.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(otherName, style: Theme.of(context).textTheme.titleSmall),
                    StreamBuilder<bool>(
                      stream: null, // context.read<ChatRepository>().getUserOnlineStatus(widget.otherUserId)
                      builder: (_, snapshot) => Text(
                        'Nearend user',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              if (_chat?.listingTitle != null) _buildListingBanner(),
              Expanded(child: _buildMessageList(state)),
              _buildInputBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      color: AppColors.primaryContainer,
      child: Row(
        children: [
          if (_chat?.listingImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: CachedNetworkImage(
                imageUrl: _chat!.listingImageUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          if (_chat?.listingImageUrl != null) const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              _chat?.listingTitle ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState state) {
    if (state is ChatLoading) return const LoadingWidget();
    if (state is ChatError) return AppErrorWidget(message: state.message);

    final messages = state is ChatMessagesLoaded ? state.messages : <MessageEntity>[];

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                size: 48, color: AppColors.textHint),
            const SizedBox(height: AppDimensions.md),
            Text(
              'Start the conversation!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final msg = messages[i];
        final isMe = msg.senderId == widget.currentUserId;
        return _MessageBubble(
          message: msg,
          isMe: isMe,
        ).animate().fadeIn(delay: (i * 10).ms);
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
              onPressed: _sendImage,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm,
                  ),
                ),
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatId == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<ChatBloc>().add(ChatSendMessage(
      chatId: _chatId!,
      senderId: widget.currentUserId,
      senderName: authState.user.name,
      content: text,
    ));
    _messageController.clear();
  }

  Future<void> _sendImage() async {
    if (_chatId == null) return;
    final xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (xFile == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<ChatBloc>().add(ChatSendImage(
      chatId: _chatId!,
      senderId: widget.currentUserId,
      senderName: authState.user.name,
      image: File(xFile.path),
    ));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const SizedBox(width: AppDimensions.xs),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Container(
              padding: message.type == 'image'
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.sm,
                    ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppDimensions.radiusMd),
                  topRight: const Radius.circular(AppDimensions.radiusMd),
                  bottomLeft: Radius.circular(isMe ? AppDimensions.radiusMd : 4),
                  bottomRight: Radius.circular(isMe ? 4 : AppDimensions.radiusMd),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.type == 'image')
                    GestureDetector(
                      onTap: () => _openImage(context),
                      child: CachedNetworkImage(
                        imageUrl: message.content,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : null,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  Padding(
                    padding: message.type == 'image'
                        ? const EdgeInsets.all(4)
                        : const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppHelpers.formatChatTime(message.createdAt),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : AppColors.textHint,
                            fontSize: 10,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 14,
                            color: message.isRead ? Colors.lightBlue[200] : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: AppDimensions.xs),
        ],
      ),
    );
  }

  void _openImage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: PhotoView(imageProvider: CachedNetworkImageProvider(message.content)),
      ),
    ));
  }
}
