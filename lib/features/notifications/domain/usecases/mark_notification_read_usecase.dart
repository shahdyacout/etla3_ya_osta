import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repo/notifications_repository.dart';

class MarkNotificationReadUseCase {
  final INotificationsRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<Either<Failure, void>> call(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
