
import 'package:etla3_ya_osta/features/Auth/domain/repo%20interface/auth_repository.dart';
import '../../../../core/usecase/usecase.dart';

class LoginUseCase extends UseCase<String, String> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<String> call(String phone) async {
    return await repository.login(phone);
  }
}