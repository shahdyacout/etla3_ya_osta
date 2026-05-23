import 'dart:async';
import 'package:etla3_ya_osta/features/Auth/domain/repo%20interface/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_role.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _keyRole   = 'user_role';
  static const _keyUserId = 'user_id';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? _verificationId;

  Future<void> sendOtp(String phone) async {
    final completer = Completer<void>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+20$phone',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(e.message));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  @override
  Future<String> login(String otp) async {
    if (_verificationId == null) {
      throw Exception('Verification ID is null. Send OTP first.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    // بنجيب token جديد دايماً
    final token = await userCredential.user?.getIdToken() ?? '';
    final userId = userCredential.user?.uid ?? '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString(_keyUserId, userId);

    return token;
  }

  @override
  Future<void> selectRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyRole,
      role == UserRole.traveler ? 'traveler' : 'driver',
    );
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUserId);
  }

  @override
  Future<({String? token, UserRole? role})> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final roleStr = prefs.getString(_keyRole);

    // بنتحقق من Firebase User مباشرة
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      // مفيش user — امسح أي بيانات قديمة
      await prefs.remove('auth_token');
      return (token: null, role: null);
    }

    // بنجدد الـ token تلقائياً من Firebase
    final freshToken = await firebaseUser.getIdToken(true) ?? '';

    // بنحدث الـ token المحفوظ
    await prefs.setString('auth_token', freshToken);

    UserRole? role;
    if (roleStr != null) {
      role = roleStr == 'traveler' ? UserRole.traveler : UserRole.driver;
    }

    return (token: freshToken, role: role);
  }
}