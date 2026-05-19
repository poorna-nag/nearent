import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ChatBloc>().add(ChatLoadUserChats(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.messages),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) return const LoadingWidget();
          if (state is ChatError) return AppErrorWidget(message: state.message);
          if (state is UserChatsLoaded) {
            if (state.chats.isEmpty) {
              return const AppEmptyWidget(
                message: AppStrings.noChats,
                icon: Icons.chat_bubble_outline_rounded,
              );
            }
            return _buildChatList(state);
          }
          return const AppEmptyWidget(
            message: AppStrings.noChats,
            icon: Icons.chat_bubble_outline_rounded,
          );
        },
      ),
    );
  }

  Widget _buildChatList(UserChatsLoaded state) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.id : '';

    return ListView.separated(
      itemCount: state.chats.length,
      separatorBuilder: (_, __) => const Divider(height: 0, indent: 80),
      itemBuilder: (context, i) {
        final chat = state.chats[i];
        final otherId = chat.participantIds.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
        final otherName = chat.participantNames[otherId] ?? 'Unknown';
        final otherImage = chat.participantImages[otherId];
        final unread = chat.unreadCount[currentUserId] ?? 0;

        return ListTile(
          onTap: () => context.push(AppRoutes.chat, extra: {
            'currentUserId': currentUserId,
            'otherUserId': otherId,
            'chatId': chat.id,
          }),
          leading: CircleAvatar(
            radius: AppDimensions.avatarMd / 2,
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
                    ),
                  )
                : null,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  otherName,
                  style: TextStyle(
                    fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Text(
                AppHelpers.formatChatTime(chat.lastMessageTime),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: unread > 0 ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              if (chat.listingTitle != null) ...[
                const Icon(Icons.tag_rounded, size: 12, color: AppColors.textHint),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    chat.listingTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ] else
                Expanded(
                  child: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              if (unread > 0)
                Container(
                  margin: const EdgeInsets.only(left: AppDimensions.sm),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
