import '../../data/repo/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/select_role_usecase.dart';
import 'auth_cubit.dart';

AuthCubit createAuthCubit() {
  final repository = AuthRepositoryImpl();
  return AuthCubit(
    loginUseCase: LoginUseCase(repository),
    selectRoleUseCase: SelectRoleUseCase(repository),
    repository: repository,
  );
}