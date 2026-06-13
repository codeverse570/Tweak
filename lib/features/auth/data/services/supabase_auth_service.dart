import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:skillyr/features/auth/domain/models/auth_model.dart' as app;
import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../domain/models/auth_state.dart' as app;
import 'auth_service.dart';

/// Production Supabase implementation of [AuthService].
///
/// Setup (pubspec.yaml):
/// ```yaml
/// dependencies:
///   supabase_flutter: ^2.5.0
///   google_sign_in: ^6.2.1
/// ```
///
/// Initialise once in main():
/// ```dart
/// await Supabase.initialize(
///   url: 'https://YOUR_PROJECT.supabase.co',
///   anonKey: 'YOUR_ANON_KEY',
/// );
/// ```
///
/// Supabase dashboard → Authentication → Providers → Google:
///   • Enable Google provider
///   • Paste your Web Client ID + Secret from Google Cloud Console
///   • Add redirect URL: com.yourapp://login-callback
///
/// Android: add to android/app/src/main/res/values/strings.xml:
///   <string name="default_web_client_id">YOUR_WEB_CLIENT_ID</string>
class SupabaseAuthService implements AuthService {
  SupabaseAuthService({String? iosClientId, String? webClientId})
      : _googleSignIn = GoogleSignIn(
          clientId: iosClientId,       // iOS only; null on Android = uses strings.xml
          serverClientId: webClientId, // needed on Android for id_token
          scopes: ['email', 'profile'],
        );

  final GoogleSignIn _googleSignIn;
  final _client = Supabase.instance.client;

  // ─── Stream ──────────────────────────────────────────────────────────────

  @override
  Stream<app.AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final session = data.session;
      if (session == null) return const app.AuthState();
      return _sessionToState(session);
    });
  }

  // ─── Google OAuth ────────────────────────────────────────────────────────

  @override
  Future<app.AuthState> signInWithGoogle() async {
    try {
      // 1. Trigger native Google account picker
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the picker
        return const app.AuthState(status: app.AuthStatus.unauthenticated);
      }

      // 2. Get Google auth tokens
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        return const app.AuthState(
          status: app.AuthStatus.error,
          errorMessage: 'Google sign-in failed — no ID token returned.',
        );
      }

      // 3. Exchange with Supabase
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.session == null) {
        return const app.AuthState(
          status: app.AuthStatus.error,
          errorMessage: 'Supabase session not created.',
        );
      }

      return _sessionToState(response.session!);
    } on AuthException catch (e) {
      return app.AuthState(
        status: app.AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      return app.AuthState(
        status: app.AuthStatus.error,
        errorMessage: 'Sign-in failed. Please try again.',
      );
    }
  }

  // ─── Email ───────────────────────────────────────────────────────────────

  @override
  Future<app.AuthState> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session == null) {
        return const app.AuthState(
          status: app.AuthStatus.error,
          errorMessage: 'Login failed — check your credentials.',
        );
      }
      return _sessionToState(response.session!);
    } on AuthException catch (e) {
      return app.AuthState(
        status: app.AuthStatus.error,
        errorMessage: e.message,
      );
    }
  }

  // ─── Sign out ────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // clear Google token cache
    await _client.auth.signOut();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  app.AuthState _sessionToState(Session session) {
    final user = session.user;
    final meta = user.userMetadata ?? {};
    return app.AuthState(
      status: app.AuthStatus.authenticated,
      userId: user.id,
      email: user.email,
      displayName: meta['full_name'] as String? ??
          meta['name'] as String? ??
          user.email?.split('@').first,
      photoUrl: meta['avatar_url'] as String?,
    );
  }
}