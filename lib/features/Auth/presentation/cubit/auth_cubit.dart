import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/auth_state.dart';
import 'package:etla3_ya_osta/core/entities/user_role_entity.dart';
import '../../data/repo/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/select_role_usecase.dart';
import '../../../../core/error/failures.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final SelectRoleUseCase _selectRoleUseCase;
  final AuthRepositoryImpl _repository;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required SelectRoleUseCase selectRoleUseCase,
    required AuthRepositoryImpl repository,
  }) : _loginUseCase = loginUseCase,
       _selectRoleUseCase = selectRoleUseCase,
       _repository = repository,
       super(const AuthState());

  Future<void> checkAuth() async {
    emit(state.copyWith(isLoading: true));
    try {
      final session = await _repository.getSession();
      if (session.token != null && session.role != null) {
        emit(
          state.copyWith(
            isLoading: false,
            token: session.token,
            role: session.role,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } on Exception {
      emit(state.copyWith(isLoading: false, failure: const CacheFailure()));
    }
  }

  Future<void> selectRole(UserRole role) async {
    try {
      await _selectRoleUseCase(role);
      emit(state.copyWith(role: role));
    } on Exception {
      emit(state.copyWith(failure: const CacheFailure()));
    }
  }

  Future<void> sendOtp(String phone) async {
    await _repository.sendOtp(phone);
  }

  Future<void> login(String otp) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    try {
      final token = await _loginUseCase(otp);
      emit(state.copyWith(isLoading: false, token: token));
    } on Exception catch (e) {
      emit(
        state.copyWith(isLoading: false, failure: ServerFailure(e.toString())),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      emit(const AuthState());
    } on Exception {
      emit(state.copyWith(failure: const CacheFailure()));
    }
  }
}
