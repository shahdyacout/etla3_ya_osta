import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.createdAt,
    super.isRead,
    super.imageUrl,
    super.actionRoute,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: _parseType(data['type']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      imageUrl: data['imageUrl'],
      actionRoute: data['actionRoute'],
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'trip':
        return NotificationType.trip;
      case 'payment':
        return NotificationType.payment;
      case 'promo':
        return NotificationType.promo;
      default:
        return NotificationType.system;
    }
  }
}
