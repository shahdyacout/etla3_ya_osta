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

abstract class Either<L, R> {
  const Either();
  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
  @override
  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn) => leftFn(value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
  @override
  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn) => rightFn(value);
}