import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationEvent {
  final String userId;
  const NotificationsLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class NotificationMarkReadRequested extends NotificationEvent {
  final String notificationId;
  const NotificationMarkReadRequested(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkAllReadRequested extends NotificationEvent {
  final String userId;
  const NotificationMarkAllReadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class NotificationDeleteRequested extends NotificationEvent {
  final String notificationId;
  const NotificationDeleteRequested(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}
