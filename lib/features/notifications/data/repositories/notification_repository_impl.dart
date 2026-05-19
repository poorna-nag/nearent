import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  const NotificationRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _col => _firestore.collection('notifications');

  @override
  Stream<List<NotificationEntity>> getNotifications(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromFirestore(d))
            .toList());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _col.doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _col.doc(notificationId).delete();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snap.count ?? 0;
  }
}
