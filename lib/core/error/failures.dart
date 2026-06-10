abstract class Failure {
  final String message;
  const Failure(this.message);
}

// مفيش انترنت
class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

// خطأ عام من Firebase
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong']);
}

// خطأ في البيانات المحلية
class CacheFailure extends Failure {
  const CacheFailure() : super('Local data error');
}

// input غلط من المستخدم
class InvalidInputFailure extends Failure {
  const InvalidInputFailure(super.message);
}

// المستخدم مش logged in
class AuthFailure extends Failure {
  const AuthFailure() : super('User not authenticated');
}

// الرصيد مش كفاية للسحب
class InsufficientBalanceFailure extends Failure {
  const InsufficientBalanceFailure() : super('Insufficient balance');
}