import 'package:etla3_ya_osta/features/Auth/domain/repo%20interface/auth_repository.dart';
import '../entities/user_role_entity.dart';
import '../../../../core/usecase/usecase.dart';

class SelectRoleUseCase extends UseCase<void, UserRole> {
  final AuthRepository repository;

  SelectRoleUseCase(this.repository);

  @override
  Future<void> call(UserRole role) async {
    await repository.selectRole(role);
  }
}
