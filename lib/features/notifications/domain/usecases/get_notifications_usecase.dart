import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';
import '../repo/notifications_repository.dart';

class GetNotificationsUseCase {
  final INotificationsRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<Either<Failure, List<NotificationEntity>>> call() {
    return _repository.getNotifications();
  }
}
