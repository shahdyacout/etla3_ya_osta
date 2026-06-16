enum NotificationType { trip, payment, system, promo }

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? actionRoute;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.actionRoute,
  });
}
