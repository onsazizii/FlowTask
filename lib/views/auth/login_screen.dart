import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'recaptcha.dart';
import 'package:onsaziziproject/views/auth/registerscreen.dart';

import '../../providers/auth_provider.dart';

const kPurpleDark = Color(0xFF4A0A7A);
const kPurpleBorder = Color(0xFF6A2C9A);
const kBackground = Color(0xFFF7F5FC);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _siteKey = '6Le7jg0uAAAAANjUQMOpshnTFRHANXwqYIv9CjYO';

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _keepSignedIn = true;
  bool _loading = false;
  String? _captchaToken;
  int _captchaNonce = 0;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (_captchaToken == null) {
      _showError('Please complete the reCAPTCHA.');
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signIn(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
            rememberMe: _keepSignedIn,
          );
      // Navigation is usually handled by an auth-state listener.
    } on FirebaseAuthException catch (e) {
      _showError(_messageFor(e.code));
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        // A reCAPTCHA token only works once, so reset it after each attempt.
        setState(() {
          _loading = false;
          _captchaToken = null;
          _captchaNonce++;
        });
      }
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // Top-right blobs
          Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              width: 160,
              height: 190,
              child: CustomPaint(painter: TopBlobPainter()),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Header
                        Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.maybePop(context),
                              child: const Icon(Icons.arrow_back,
                                  color: kPurpleDark, size: 30),
                            ),
                            const SizedBox(width: 14),
                            Flexible(
                              child: Text(
                                'GET STARTED',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: kPurpleDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Welcome\n Back !',
                            style: GoogleFonts.montserrat(
                              fontSize: 28,
                              height: 1.3,
                              fontWeight: FontWeight.w800,
                              color: kPurpleDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email
                        _field(
                          hint: 'Email',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Enter your email';
                            if (!t.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Password
                        _field(
                          hint: 'Password',
                          controller: _passwordCtrl,
                          obscure: _obscure,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter your password'
                              : null,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // reCAPTCHA
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: RecaptchaBox(
                            key: ValueKey(_captchaNonce),
                            siteKey: _siteKey,
                            onChanged: (token) =>
                                setState(() => _captchaToken = token),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Keep me signed-in
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _keepSignedIn,
                                onChanged: (v) =>
                                    setState(() => _keepSignedIn = v ?? false),
                                activeColor: kPurpleDark,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2)),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Keep me signed-in',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Login button
                        Center(
                          child: SizedBox(
                            width: 154,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPurpleDark,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: kPurpleDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Sign-up link
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Don’t have an account',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: kPurpleDark,
                                    decoration: TextDecoration.underline,
                                    decorationColor: kPurpleDark,
                                  ),
                                ),
                                TextSpan(
                                  text: '?',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: kPurpleDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: GoogleFonts.montserrat(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.montserrat(fontSize: 14, color: Colors.black87),
          suffixIcon: suffix,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: kPurpleBorder, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: kPurpleDark, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class TopBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Darker, upper blob
    final dark = Path()
      ..moveTo(w * 0.15, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.55)
      ..cubicTo(w * 0.85, h * 0.62, w * 0.55, h * 0.50, w * 0.40, h * 0.30)
      ..cubicTo(w * 0.28, h * 0.14, w * 0.10, h * 0.10, w * 0.15, 0)
      ..close();
    canvas.drawPath(dark, Paint()..color = const Color(0xFFD7B5EA));

    // Lighter, lower blob
    final light = Path()
      ..moveTo(w * 0.40, h * 0.30)
      ..cubicTo(w * 0.55, h * 0.50, w * 0.85, h * 0.62, w, h * 0.55)
      ..lineTo(w, h * 0.90)
      ..cubicTo(w * 0.80, h * 0.95, w * 0.40, h * 0.85, w * 0.30, h * 0.60)
      ..cubicTo(w * 0.26, h * 0.48, w * 0.30, h * 0.38, w * 0.40, h * 0.30)
      ..close();
    canvas.drawPath(light, Paint()..color = const Color(0xFFE6D3F2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}