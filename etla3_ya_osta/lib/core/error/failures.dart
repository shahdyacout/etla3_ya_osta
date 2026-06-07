abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong']);
}

class CacheFailure extends Failure {
  const CacheFailure() : super('Local data error');
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure(super.message);
}