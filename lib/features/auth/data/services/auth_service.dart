import 'dart:async';
import 'package:skillyr/features/auth/domain/models/auth_model.dart';


/// Abstract contract for authentication.
/// Concrete implementations: [SupabaseAuthService] (prod), [MockAuthService] (dev).
abstract class AuthService {
  Future<AuthState> signInWithGoogle();
  Future<AuthState> signInWithEmail({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Stream<AuthState> get authStateChanges;
}

// ─── Mock (dev / unit tests) ─────────────────────────────────────────────────

class MockAuthService implements AuthService {
  final _controller = StreamController<AuthState>.broadcast();

  void _emit(AuthState state) => _controller.add(state);

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

  @override
  Future<AuthState> signInWithGoogle() async {
    _emit(const AuthState(status: AuthStatus.loading));
    await Future.delayed(const Duration(seconds: 2));
    const state = AuthState(
      status: AuthStatus.authenticated,
      userId: 'google_mock_uid',
      displayName: 'Niraj Kumar',
      email: 'niraj@gmail.com',
    );
    _emit(state);
    return state;
  }

  @override
  Future<AuthState> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _emit(const AuthState(status: AuthStatus.loading));
    await Future.delayed(const Duration(seconds: 2));

    if (password.length < 6) {
      const state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Password must be at least 6 characters.',
      );
      _emit(state);
      return state;
    }

    final state = AuthState(
      status: AuthStatus.authenticated,
      userId: 'email_mock_uid',
      displayName: email.split('@').first,
      email: email,
    );
    _emit(state);
    return state;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void dispose() => _controller.close();
}