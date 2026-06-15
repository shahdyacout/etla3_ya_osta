# Wallet Presentation Layer

## Overview
هذا المجلد يحتوي على طبقة العرض (Presentation Layer) لميزة المحفظة في التطبيق. يتم استخدام BLoC pattern مع Flutter Bloc لإدارة الحالة.

## المكونات الرئيسية

### Cubit
- **`wallet_cubit.dart`**: يحتوي على WalletCubit الذي يدير جميع عمليات المحفظة
  - `getBalance()`: جلب رصيد المحفظة
  - `getEarnings()`: جلب بيانات الأرباح (يومي وأسبوعي)
  - `getTransactions()`: جلب قائمة المعاملات
  - `withdrawFunds(amount)`: سحب الأموال
  - `clearFailure()`: حذف رسالة الخطأ
  - `reset()`: إعادة تعيين الحالة

- **`wallet_state.dart`**: يحتوي على WalletState الذي يمثل حالة المحفظة
  - `wallet`: بيانات المحفظة (الرصيد والإيداع التأميني)
  - `earnings`: بيانات الأرباح
  - `transactions`: قائمة المعاملات
  - `isLoading`: حالة التحميل
  - `isWithdrawing`: حالة السحب
  - `failure`: رسالة الخطأ

### Pages
- **`wallet_pages.dart`**: الصفحة الرئيسية للمحفظة
  - عرض رصيد المحفظة
  - عرض الإيداع التأميني
  - عرض إحصائيات الأرباح
  - عرض سجل المعاملات
  - زر السحب

- **`transaction_pages.dart`**: صفحة تفاصيل المعاملات
  - عرض قائمة كاملة بجميع المعاملات
  - إمكانية التحديث بسحب من الأعلى

### Widgets
- **`balance_card.dart`**: بطاقة عرض الرصيد
  - تصميم متدرج (Gradient)
  - عرض الرصيد والعملة

- **`earning_widgets.dart`**: عرض إحصائيات الأرباح
  - شبكة ثنائية الأعمدة
  - عرض الأرباح اليومية والأسبوعية

- **`transaction_title.dart`**: عنوان قسم المعاملات

- **`withdraw_bottom_sheet.dart`**: شاشة السحب (Bottom Sheet)
  - إدخال مبلغ السحب
  - التحقق من صحة المبلغ
  - عرض الرصيد المتاح

## الاستخدام

### إضافة WalletCubit في main.dart أو provider
```dart
BlocProvider(
  create: (context) => WalletCubit(
    getBalanceUseCase: getIt<GetBalanceUseCase>(),
    getEarningsUseCase: getIt<GetEarningsUseCase>(),
    getTransactionsUseCase: getIt<GetTransactionsUseCase>(),
    withdrawFundsUseCase: getIt<WithdrawFundsUseCase>(),
  ),
  child: const MyApp(),
),
```

### الانتقال إلى صفحة المحفظة
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const WalletPage()),
);
```

## الحالات المختلفة

### Loading State
- عند جلب البيانات، يتم عرض `CircularProgressIndicator`

### Error State
- عند حدوث خطأ، يتم عرض `SnackBar` برسالة الخطأ

### Empty State
- عندما لا توجد معاملات، يتم عرض رسالة "No Transactions Yet"

### Success State
- عند نجاح العملية، يتم تحديث الحالة وعرض البيانات

## التصميم
- الألوان الأساسية: أخضر/أزرق (Teal) للعناصر الرئيسية
- الألوان الثانوية: أخضر للدخل، أحمر للنفقات
- Border Radius: 12-16 للعناصر الرئيسية
- Padding: 16 للمسافات الأفقية

## ملاحظات مهمة
- تأكد من توفير جميع use cases المطلوبة عند إنشاء WalletCubit
- يتم استخدام BlocListener لعرض رسائل الخطأ
- يتم استخدام BlocBuilder لتحديث الواجهة حسب الحالة
- يتم استخدام BlocConsumer في WithdrawBottomSheet لاستماع ورسم الحالة في نفس الوقت

