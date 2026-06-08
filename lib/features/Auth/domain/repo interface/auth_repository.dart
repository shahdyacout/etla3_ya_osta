import '../entities/user_role_entity.dart';

abstract class AuthRepository {
  Future<String> login(String phone);
  Future<void> selectRole(UserRole role);
  Future<void> logout();
  Future<({String? token, UserRole? role})> getSession();
}
