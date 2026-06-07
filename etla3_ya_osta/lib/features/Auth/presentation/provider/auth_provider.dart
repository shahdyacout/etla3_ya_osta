import 'package:etla3_ya_osta/features/Auth/data/repo/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/select_role_usecase.dart';
import '../../../../core/error/failures.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(),
);

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);

final selectRoleUseCaseProvider = Provider(
  (ref) => SelectRoleUseCase(ref.read(authRepositoryProvider)),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final SelectRoleUseCase _selectRoleUseCase;
  final AuthRepositoryImpl _repository;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required SelectRoleUseCase selectRoleUseCase,
    required AuthRepositoryImpl repository,
  })  : _loginUseCase = loginUseCase,
        _selectRoleUseCase = selectRoleUseCase,
        _repository = repository,
        super(const AuthState());

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);

    try {
      final session = await _repository.getSession();

      if (session.token != null && session.role != null) {
        state = state.copyWith(
          isLoading: false,
          token: session.token,
          role: session.role,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } on Exception {
      state = state.copyWith(
        isLoading: false,
        failure: const CacheFailure(),
      );
    }
  }

  Future<void> selectRole(UserRole role) async {
    try {
      await _selectRoleUseCase(role);
      state = state.copyWith(role: role);
    } on Exception {
      state = state.copyWith(
        failure: const CacheFailure(),
      );
    }
  }

  Future<void> login(String phone) async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    try {
      final token = await _loginUseCase(phone);
      state = state.copyWith(
        isLoading: false,
        token: token,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: ServerFailure(e.toString()),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      state = const AuthState();
    } on Exception {
      state = state.copyWith(
        failure: const CacheFailure(),
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    loginUseCase: ref.read(loginUseCaseProvider),
    selectRoleUseCase: ref.read(selectRoleUseCaseProvider),
    repository: ref.read(authRepositoryProvider),
  ),
);