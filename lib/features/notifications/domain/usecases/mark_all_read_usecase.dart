import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repo/notifications_repository.dart';

class MarkAllNotificationsReadUseCase {
  final INotificationsRepository _repository;

  MarkAllNotificationsReadUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.markAllAsRead();
  }
}
