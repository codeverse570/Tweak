/// Represents the authentication status of the user.
enum AuthStatus {
  /// Initial state — no auth attempt has been made yet.
  unauthenticated,

  /// An auth operation is in progress (sign-in, sign-up, etc.).
  loading,

  /// The user is signed in.
  authenticated,

  /// An auth operation failed.
  error,
}

/// Immutable snapshot of the auth state.
class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.userId,
    this.displayName,
    this.email,
    this.photoUrl,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? userId;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? displayName,
    String? email,
    String? photoUrl,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Clears error state back to unauthenticated.
  AuthState clearError() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  @override
  String toString() =>
      'AuthState(status: $status, userId: $userId, email: $email)';
}