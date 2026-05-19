import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationBloc>().add(
            NotificationsLoadRequested(authState.user.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                final authState = context.read<AuthBloc>().state;
                return TextButton(
                  onPressed: () {
                    if (authState is AuthAuthenticated) {
                      context.read<NotificationBloc>().add(
                            NotificationMarkAllReadRequested(authState.user.id),
                          );
                    }
                  },
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) return const LoadingWidget();
          if (state is NotificationError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<NotificationBloc>().add(
                        NotificationsLoadRequested(authState.user.id),
                      );
                }
              },
            );
          }
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const AppEmptyWidget(
                message: 'No notifications yet',
                icon: Icons.notifications_off_outlined,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = state.notifications[i];
                return Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppDimensions.lg),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context.read<NotificationBloc>().add(
                          NotificationDeleteRequested(n.id),
                        );
                  },
                  child: ListTile(
                    tileColor: n.isRead ? null : AppColors.primaryContainer.withValues(alpha: 0.3),
                    leading: CircleAvatar(
                      backgroundColor: _typeColor(n.type).withValues(alpha: 0.15),
                      child: Icon(_typeIcon(n.type), color: _typeColor(n.type), size: 20),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          timeago.format(n.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textHint,
                              ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (!n.isRead) {
                        context.read<NotificationBloc>().add(
                              NotificationMarkReadRequested(n.id),
                            );
                      }
                    },
                  ).animate().fadeIn(delay: (i * 30).ms),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'listing':
        return Icons.sell_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'chat':
        return AppColors.secondary;
      case 'listing':
        return AppColors.primary;
      default:
        return AppColors.accent;
    }
  }
}
