import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/notification_model.dart';

class NotificationsFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationsFirestoreDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return uid;
  }

  CollectionReference get _notificationsRef =>
      _firestore.collection('users').doc(_uid).collection('notifications');

  Future<List<NotificationModel>> getNotifications() async {
    final snap = await _notificationsRef
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map(NotificationModel.fromFirestore).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    final snap = await _notificationsRef.where('isRead', isEqualTo: false).get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<int> getUnreadCount() async {
    final snap = await _notificationsRef
        .where('isRead', isEqualTo: false)
        .get();
    return snap.docs.length;
  }
}
