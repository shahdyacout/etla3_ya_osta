import '../../../../core/error/failures.dart';
import '../../../../core/entities/user_role_entity.dart';

class AuthState {
  final bool isLoading;
  final String? token;
  final UserRole? role;
  final String? userId;
  final Failure? failure;  // ← بدلنا String? error بـ Failure?

  const AuthState({
    this.isLoading = false,
    this.token,
    this.role,
    this.userId,
    this.failure,
  });

  bool get isAuthenticated => token != null;

  // هل في error؟
  bool get hasError => failure != null;

  AuthState copyWith({
    bool? isLoading,
    String? token,
    UserRole? role,
    String? userId,
    Failure? failure,
    bool clearFailure = false,  // ← عشان نمسح الـ error بعد ما يتعرض
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}