import 'dart:async';
import 'package:etla3_ya_osta/features/Auth/domain/repo%20interface/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:etla3_ya_osta/core/entities/user_role_entity.dart';
import 'package:flutter/foundation.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _keyRole = 'user_role';
  static const _keyUserId = 'user_id';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    final token = await userCredential.user?.getIdToken() ?? '';
    final userId = userCredential.user?.uid ?? '';
    final phone = userCredential.user?.phoneNumber ?? '';

    final prefs = await SharedPreferences.getInstance();
    final selectedRole = prefs.getString(_keyRole);

    // بنحفظ المستخدم في Firestore
    await _firestore.collection('users').doc(userId).set({
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      if (selectedRole != null) 'role': selectedRole,
    }, SetOptions(merge: true));

    await prefs.setString('auth_token', token);
    await prefs.setString(_keyUserId, userId);

    return token;
  }

  @override
  Future<void> selectRole(UserRole role) async {
    final roleStr = role == UserRole.traveler ? 'traveler' : 'driver';

    // وكمان في SharedPreferences كـ cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, roleStr);

    // بنحفظ الـ role في Firestore
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('users').doc(userId).set({
        'role': roleStr,
      }, SetOptions(merge: true));
    }
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
    await prefs.reload(); // إجبار النظام على قراءة أحدث بيانات من التخزين
    
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return (token: null, role: null);
    }

    // قراءة البيانات المحفوظة محلياً
    final cachedToken = prefs.getString('auth_token');
    final cachedRoleStr = prefs.getString(_keyRole);

    UserRole? role;
    if (cachedRoleStr == 'traveler') {
      role = UserRole.traveler;
    } else if (cachedRoleStr == 'driver') {
      role = UserRole.driver;
    }

    // لو البيانات كاملة في الكاش نرجعها فوراً
    if (cachedToken != null && role != null) {
      _refreshTokenInBackground(firebaseUser, prefs);
      return (token: cachedToken, role: role);
    }

    // لو مش كاملة، نجيب التوكن والروول من السيرفر
    final freshToken = await firebaseUser.getIdToken(true);
    await prefs.setString('auth_token', freshToken!);

    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final roleStr = doc.data()?['role'] as String?;
      if (roleStr == 'traveler') {
        role = UserRole.traveler;
        await prefs.setString(_keyRole, 'traveler');
      } else if (roleStr == 'driver') {
        role = UserRole.driver;
        await prefs.setString(_keyRole, 'driver');
      }
    } catch (e) {
      debugPrint("Error fetching role from Firestore: $e");
    }

    return (token: freshToken, role: role);
  }

  Future<void> _refreshTokenInBackground(
    User firebaseUser,
    SharedPreferences prefs,
  ) async {
    try {
      final freshToken = await firebaseUser.getIdToken(true);
      await prefs.setString('auth_token', freshToken!);
    } catch (_) {}
  }
}
