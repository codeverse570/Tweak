import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:skillyr/features/auth/data/services/auth_service.dart';
import 'package:skillyr/features/auth/domain/models/auth_model.dart';



/// Single source of truth for auth state.
///
/// Wire at app root:
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => AuthProvider(SupabaseAuthService(...)),
/// )
/// ```
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _subscription = _service.authStateChanges.listen((state) {
      _state = state;
      notifyListeners();
    });
  }

  final AuthService _service;
  late final StreamSubscription<AuthState> _subscription;

  AuthState _state = const AuthState();

  // ─── State ───────────────────────────────────────────────────────────────

  AuthState get state => _state;
  AuthStatus get status => _state.status;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  String? get displayName => _state.displayName;
  String? get email => _state.email;

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    await _service.signInWithGoogle();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _service.signInWithEmail(email: email, password: password);
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  void clearError() {
    _state = _state.clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}