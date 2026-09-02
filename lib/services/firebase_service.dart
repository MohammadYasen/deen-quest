import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _isInitialized = true;
      debugPrint('[FirebaseService] Firebase initialized successfully.');
    } catch (e) {
      _isInitialized = false;
      debugPrint('[FirebaseService] Firebase not configured yet, running in offline/local mode: $e');
    }
  }
}
