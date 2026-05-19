import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationInitial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
    on<NotificationDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    NotificationsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    await emit.forEach(
      _repository.getNotifications(event.userId),
      onData: (notifications) {
        final unread = notifications.where((n) => !n.isRead).length;
        return NotificationsLoaded(notifications: notifications, unreadCount: unread);
      },
      onError: (e, _) => NotificationError(e.toString()),
    );
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.notificationId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllRead(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAllAsRead(event.userId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onDelete(
    NotificationDeleteRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.deleteNotification(event.notificationId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
