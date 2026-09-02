import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'firebase_service.dart';
import 'local_storage_service.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAnonymous => _currentUser?.isAnonymous ?? false;

  final _authStreamController = StreamController<UserProfile?>.broadcast();
  Stream<UserProfile?> get authStateChanges => _authStreamController.stream;

  Future<void> init() async {
    await LocalStorageService.instance.init();
    
    // Check local stored session
    final saved = LocalStorageService.instance.getJson('current_user_profile');
    if (saved != null) {
      _currentUser = UserProfile.fromJson(Map<String, dynamic>.from(saved));
      _authStreamController.add(_currentUser);
    }

    if (FirebaseService.instance.isInitialized) {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          _currentUser = UserProfile(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName ?? (user.isAnonymous ? 'زائر' : 'طالب علم'),
            photoUrl: user.photoURL,
            isAnonymous: user.isAnonymous,
            lastLoginAt: DateTime.now(),
          );
          _saveLocalProfile();
        } else {
          if (_currentUser != null && !_currentUser!.isAnonymous) {
            _currentUser = null;
            LocalStorageService.instance.remove('current_user_profile');
          }
        }
        _authStreamController.add(_currentUser);
        notifyListeners();
      });
    }
  }

  void _saveLocalProfile() {
    if (_currentUser != null) {
      LocalStorageService.instance.saveJson('current_user_profile', _currentUser!.toJson());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (FirebaseService.instance.isInitialized) {
      try {
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = cred.user!;
        _currentUser = UserProfile(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName ?? 'طالب علم',
          isAnonymous: false,
          lastLoginAt: DateTime.now(),
        );
        _saveLocalProfile();
        notifyListeners();
        return;
      } on FirebaseAuthException catch (e) {
        throw mapFirebaseError(e.code);
      }
    } else {
      // Offline fallback simulation
      await Future.delayed(const Duration(milliseconds: 400));
      _currentUser = UserProfile(
        uid: 'local_user_${email.hashCode}',
        email: email,
        displayName: email.split('@').first,
        isAnonymous: false,
        lastLoginAt: DateTime.now(),
      );
      _saveLocalProfile();
      _authStreamController.add(_currentUser);
      notifyListeners();
    }
  }

  Future<void> registerWithEmail(String email, String password, String displayName) async {
    if (FirebaseService.instance.isInitialized) {
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = cred.user!;
        await user.updateDisplayName(displayName.trim());
        _currentUser = UserProfile(
          uid: user.uid,
          email: user.email,
          displayName: displayName.trim(),
          isAnonymous: false,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        _saveLocalProfile();
        notifyListeners();
        return;
      } on FirebaseAuthException catch (e) {
        throw mapFirebaseError(e.code);
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      _currentUser = UserProfile(
        uid: 'local_user_${email.hashCode}',
        email: email,
        displayName: displayName.trim(),
        isAnonymous: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      _saveLocalProfile();
      _authStreamController.add(_currentUser);
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    if (FirebaseService.instance.isInitialized) {
      try {
        final cred = await FirebaseAuth.instance.signInAnonymously();
        final user = cred.user!;
        _currentUser = UserProfile(
          uid: user.uid,
          displayName: 'زائر نور',
          isAnonymous: true,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        _saveLocalProfile();
        notifyListeners();
        return;
      } on FirebaseAuthException catch (e) {
        throw mapFirebaseError(e.code);
      }
    } else {
      _currentUser = UserProfile(
        uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        displayName: 'زائر نور',
        isAnonymous: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      _saveLocalProfile();
      _authStreamController.add(_currentUser);
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      } on FirebaseAuthException catch (e) {
        throw mapFirebaseError(e.code);
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  Future<void> signOut() async {
    if (FirebaseService.instance.isInitialized) {
      await FirebaseAuth.instance.signOut();
    }
    _currentUser = null;
    await LocalStorageService.instance.remove('current_user_profile');
    _authStreamController.add(null);
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseAuth.instance.currentUser?.delete();
      } on FirebaseAuthException catch (e) {
        throw mapFirebaseError(e.code);
      }
    }
    _currentUser = null;
    await LocalStorageService.instance.remove('current_user_profile');
    _authStreamController.add(null);
    notifyListeners();
  }

  static String mapFirebaseError(String code) {
    return switch (code) {
      'user-not-found' => 'لم يتم العثور على حساب مسجل بهذا البريد الإلكتروني.',
      'wrong-password' => 'كلمة المرور غير صحيحة، يرجى التحقق وإعادة المحاولة.',
      'email-already-in-use' => 'هذا البريد الإلكتروني مستخدم بالفعل في حساب آخر.',
      'invalid-email' => 'صيغة البريد الإلكتروني غير صحيحة.',
      'weak-password' => 'كلمة المرور ضعيفة جدًا؛ يُرجى إدخال 6 أحرف أو أرقام على الأقل.',
      'network-request-failed' => 'تعذر الاتصال بالشبكة، تأكد من اتصال هاتفك بالإنترنت.',
      'user-disabled' => 'تم تعطيل هذا الحساب من قِبل إدارة التطبيق.',
      'too-many-requests' => 'محاولات دخول كثيرة خاطئة، يرجى الانتظار قليلاً ثم المحاولة.',
      'operation-not-allowed' => 'تسجيل الدخول بهذه الطريقة غير مفعّل حالياً.',
      _ => 'حدث خطأ أثناء الاتصال بالخادم ($code). يرجى المحاولة لاحقًا.',
    };
  }
}
