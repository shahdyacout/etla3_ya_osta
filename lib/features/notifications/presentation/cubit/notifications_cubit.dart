import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/mark_all_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markAsRead;
  final MarkAllNotificationsReadUseCase _markAllRead;

  NotificationsCubit({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markAsRead,
    required MarkAllNotificationsReadUseCase markAllRead,
  })  : _getNotifications = getNotifications,
        _markAsRead = markAsRead,
        _markAllRead = markAllRead,
        super(const NotificationsState());

  Future<void> loadNotifications() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final result = await _getNotifications();
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        failure: failure.message,
      )),
      (notifications) => emit(state.copyWith(
        isLoading: false,
        notifications: notifications,
        unreadCount: notifications.where((n) => !n.isRead).length,
        clearFailure: true,
      )),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await _markAsRead(notificationId);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure.message)),
      (_) {
        final updated = state.notifications.map((n) {
          if (n.id == notificationId) {
            return NotificationEntity(
              id: n.id,
              title: n.title,
              body: n.body,
              type: n.type,
              createdAt: n.createdAt,
              isRead: true,
              imageUrl: n.imageUrl,
              actionRoute: n.actionRoute,
            );
          }
          return n;
        }).toList();
        emit(state.copyWith(
          notifications: updated,
          unreadCount: updated.where((n) => !n.isRead).length,
        ));
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await _markAllRead();
    result.fold(
      (failure) => emit(state.copyWith(failure: failure.message)),
      (_) {
        final updated = state.notifications.map((n) {
          return NotificationEntity(
            id: n.id,
            title: n.title,
            body: n.body,
            type: n.type,
            createdAt: n.createdAt,
            isRead: true,
            imageUrl: n.imageUrl,
            actionRoute: n.actionRoute,
          );
        }).toList();
        emit(state.copyWith(
          notifications: updated,
          unreadCount: 0,
        ));
      },
    );
  }
}
