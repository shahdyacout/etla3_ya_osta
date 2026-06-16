import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repo/notifications_repository.dart';
import '../data_source/notifications_firestore_ds.dart';

class NotificationsRepositoryImpl implements INotificationsRepository {
  final NotificationsFirestoreDataSource _dataSource;

  NotificationsRepositoryImpl(this._dataSource);

  Failure _handleException(Object e) {
    if (e is Failure) return e;
    if (e is FirebaseException) {
      switch (e.code) {
        case 'unavailable':
        case 'network-request-failed':
          return const NetworkFailure();
        case 'permission-denied':
          return const AuthFailure();
        default:
          return ServerFailure(e.message ?? 'Firebase error');
      }
    }
    return ServerFailure(e.toString());
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final notifications = await _dataSource.getNotifications();
      return Right(notifications);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _dataSource.markAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _dataSource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await _dataSource.getUnreadCount();
      return Right(count);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
}
