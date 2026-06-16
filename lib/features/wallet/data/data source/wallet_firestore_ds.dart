import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../Core/error/failures.dart';
import '../dto/earnings_model.dart';
import '../dto/transaction_model.dart';
import '../dto/wallet_model.dart';

class WalletFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WalletFirestoreDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // لو المستخدم مش logged in بيرمي AuthFailure فوراً
  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthFailure();
    return uid;
  }

  DocumentReference get _walletRef =>
      _firestore.collection('wallets').doc(_uid);

  CollectionReference get _transactionsRef =>
      _walletRef.collection('transactions');

  // بتجيب بيانات الـ wallet
  // لو مفيش document بتنشئه بـ default values
  Future<WalletModel> getWallet() async {
    final doc = await _walletRef.get();
    if (!doc.exists) {
      const defaultWallet = WalletModel(
        balance: 0.0,
        insuranceDeposit: 0.0,
        currency: 'EGP',
      );
      await _walletRef.set(defaultWallet.toFirestore());
      return defaultWallet;
    }
    return WalletModel.fromFirestore(doc.data() as Map<String, dynamic>);
  }

  // بتحسب الأرباح اليومية والأسبوعية من الـ transactions مباشرة
  Future<EarningsModel> getEarnings() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

    final dailySnap = await _transactionsRef
        .where('type', isEqualTo: 'income')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .get();

    final dailyEarnings = dailySnap.docs.fold<double>(
      0.0,
          (accumulator, doc) =>
      accumulator + ((doc.data() as Map<String, dynamic>)['amount'] as num).toDouble(),
    );

    final weeklySnap = await _transactionsRef
        .where('type', isEqualTo: 'income')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .get();

    final weeklyEarnings = weeklySnap.docs.fold<double>(
      0.0,
          (accumulator, doc) =>
      accumulator + ((doc.data() as Map<String, dynamic>)['amount'] as num).toDouble(),
    );

    return EarningsModel(
      dailyEarnings: dailyEarnings,
      weeklyEarnings: weeklyEarnings,
    );
  }

  // بتجيب آخر 50 transaction مرتبة من الأحدث للأقدم
  Future<List<TransactionModel>> getTransactions() async {
    final snap = await _transactionsRef
        .orderBy('date', descending: true)
        .limit(50)
        .get();
    return snap.docs.map(TransactionModel.fromFirestore).toList();
  }

  // بتسحب فلوس باستخدام Firestore Transaction
  // عشان تضمن إن الـ balance والـ transaction اتكتبوا مع بعض أو متكتبوش خالص
  Future<void> withdrawFunds(double amount) async {
    await _firestore.runTransaction((tx) async {
      final walletDoc = await tx.get(_walletRef);
      final currentBalance =
      ((walletDoc.data() as Map<String, dynamic>)['balance'] as num)
          .toDouble();

      // لو الرصيد مش كفاية بيرمي InsufficientBalanceFailure
      if (currentBalance < amount) {
        throw const InsufficientBalanceFailure();
      }

      tx.update(_walletRef, {'balance': currentBalance - amount});

      tx.set(_transactionsRef.doc(), {
        'title': 'سحب رصيد',
        'amount': amount,
        'date': Timestamp.now(),
        'type': 'expense',
      });
    });
  }
}