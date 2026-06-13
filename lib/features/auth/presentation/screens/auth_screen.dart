import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/email_login_form.dart';
import '../widgets/social_login_button.dart';

/// Auth screen — login only (Google OAuth + email/password).
///
/// Layout: header floats in the top portion; login card is vertically
/// centred in the remaining space so it always feels mid-screen.
///
/// Wire at app root:
/// ```dart
/// Consumer<AuthProvider>(
///   builder: (_, auth, __) =>
///     auth.isAuthenticated ? const HomeScreen() : const AuthScreen(),
/// )
/// ```
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _showEmailForm = false;

  late final AnimationController _cardCtrl;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();

    _cardSlide = Tween(begin: 48.0, end: 0.0).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic),
    );
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    super.dispose();
  }

  void _revealEmailForm() => setState(() => _showEmailForm = true);

  Future<void> _handleEmailSubmit(
    String email,
    String password,
    String _,
  ) async {
    await context
        .read<AuthProvider>()
        .signInWithEmail(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;
    final error = auth.errorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      // ── Tap anywhere to dismiss keyboard ──────────────────────────────────
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Header takes a fixed 260 px; login section gets the rest.
              const headerHeight = 260.0;
              final bodyHeight = constraints.maxHeight - headerHeight;

              return Column(
                children: [
                  // ── Animated hero header ─────────────────────────────
                  const SizedBox(
                    height: headerHeight,
                    child: AuthHeader(),
                  ),

                  // ── Login card — centred in remaining space ───────────
                  SizedBox(
                    height: bodyHeight,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        // At minimum fill the available space so Center works
                        constraints:
                            BoxConstraints(minHeight: bodyHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _cardCtrl,
                                builder: (_, child) => Transform.translate(
                                  offset: Offset(0, _cardSlide.value),
                                  child: Opacity(
                                      opacity: _cardFade.value, child: child),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22),
                                  child: _LoginCard(
                                    isLoading: isLoading,
                                    error: error,
                                    showEmailForm: _showEmailForm,
                                    onGoogleTap: context
                                        .read<AuthProvider>()
                                        .signInWithGoogle,
                                    onEmailReveal: _revealEmailForm,
                                    onEmailSubmit: _handleEmailSubmit,
                                    onDismissError: () => context
                                        .read<AuthProvider>()
                                        .clearError(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Login card contents ──────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.isLoading,
    required this.error,
    required this.showEmailForm,
    required this.onGoogleTap,
    required this.onEmailReveal,
    required this.onEmailSubmit,
    required this.onDismissError,
  });

  final bool isLoading;
  final String? error;
  final bool showEmailForm;
  final VoidCallback onGoogleTap;
  final VoidCallback onEmailReveal;
  final void Function(String email, String password, String name) onEmailSubmit;
  final VoidCallback onDismissError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Headline ──────────────────────────────────────────────────
        const _Headline(),
        const SizedBox(height: 26),

        // ── Error banner ──────────────────────────────────────────────
        if (error != null) ...[
          _ErrorBanner(message: error!, onDismiss: onDismissError),
          const SizedBox(height: 16),
        ],

        // ── Google button ─────────────────────────────────────────────
        SocialLoginButton(
          provider: SocialProvider.google,
          label: 'Continue with Google',
          isLoading: isLoading,
          onTap: onGoogleTap,
        ),

        // ── Divider ───────────────────────────────────────────────────
        const _OrDivider(),

        // ── Email — collapsed button → expanded form ──────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeIn,
          crossFadeState: showEmailForm
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: SocialLoginButton(
            provider: SocialProvider.email,
            label: 'Continue with Email',
            isLoading: false,
            onTap: onEmailReveal,
          ),
          secondChild: EmailLoginForm(
            isSignUp: false,
            isLoading: isLoading,
            onSubmit: onEmailSubmit,
          ),
        ),

        const SizedBox(height: 32),

        // ── Legal footer ──────────────────────────────────────────────
        const _LegalFooter(),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.25),
        children: [
          TextSpan(
            text: 'Welcome\n',
            style: TextStyle(color: Color(0xFFE5E7EB)),
          ),
          TextSpan(
            text: 'back, challenger.',
            style: TextStyle(color: Color(0xFF8B5CF6)),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: const Color(0xFF1E1E2E))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'or',
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: const Color(0xFF1E1E2E))),
        ],
      ),
    );
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 11.5,
          height: 1.6,
        ),
        children: [
          TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
                color: Color(0xFF6B7280),
                decoration: TextDecoration.underline),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
                color: Color(0xFF6B7280),
                decoration: TextDecoration.underline),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF1F0A0A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7F1D1D), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close_rounded,
                color: Color(0xFF6B7280), size: 18),
          ),
        ],
      ),
    );
  }
}