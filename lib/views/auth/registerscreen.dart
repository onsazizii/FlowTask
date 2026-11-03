import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  String? _selectedRole;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF6500A8);
  static const Color secondaryColor = Color(0xFF9B4DCA);
  static const Color backgroundColor = Color(0xFFFAF8FC);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // REGISTER
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // If your root widget listens to authStateChanges, it will switch
      // screens automatically. Otherwise navigate here.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'weak-password':
          message = 'Password must contain at least 6 characters.';
          break;
        case 'network-request-failed':
          message = 'No internet connection.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TextStyle get fieldStyle =>
      GoogleFonts.poppins(fontSize: 14, color: Colors.black87);

  OutlineInputBorder _border({Color color = primaryColor, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // TEXT FIELD
  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isConfirmPassword = false,
    String? Function(String?)? validator,
  }) {
    final bool isSecret = isPassword || isConfirmPassword;
    final bool obscure =
        isPassword ? _obscurePassword : _obscureConfirmPassword;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isSecret ? obscure : false,
      validator: validator,
      style: fieldStyle,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(width: 1.5),
        errorBorder: _border(color: Colors.red),
        focusedErrorBorder: _border(color: Colors.red),
        errorStyle: GoogleFonts.poppins(fontSize: 10),
        suffixIcon: isSecret
            ? IconButton(
                onPressed: () {
                  setState(() {
                    if (isPassword) {
                      _obscurePassword = !_obscurePassword;
                    } else {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    }
                  });
                },
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }

  // DROPDOWN
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down,
          color: primaryColor, size: 26),
      style: fieldStyle,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(width: 1.5),
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: fieldStyle),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Please select $hint' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // DECORATIVE BACKGROUND (same position as before)
          Positioned(
            top: -5,
            left: -5,
            child: IgnorePointer(
              child: SizedBox(
                width: 190,
                height: 225,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipPath(
                      clipper: PurpleBlobClipper(),
                      child: Container(color: const Color(0xFFE6D3F2)),
                    ),
                    ClipPath(
                      clipper: PurpleBlobDarkClipper(),
                      child: Container(color: const Color(0xFFD7B5EA)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(27, 15, 27, 25),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_back,
                              color: primaryColor, size: 29),
                        ),
                        const SizedBox(width: 17),
                        Flexible(
                          child: Text(
                            'GET STARTED',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // TITLE
                    Center(
                      child: Text(
                        'Create an account',
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // NAME
                    _buildTextField(
                      hint: 'Name',
                      controller: _nameController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 18),

                    // EMAIL
                    _buildTextField(
                      hint: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                            .hasMatch(v.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // GENDER
                    _buildDropdown(
                      hint: 'Gender',
                      value: _selectedGender,
                      items: const ['Female', 'Male', 'Other'],
                      onChanged: (v) => setState(() => _selectedGender = v),
                    ),
                    const SizedBox(height: 18),

                    // ROLE
                    _buildDropdown(
                      hint: 'Role',
                      value: _selectedRole,
                      items: const ['User', 'Admin'],
                      onChanged: (v) => setState(() => _selectedRole = v),
                    ),
                    const SizedBox(height: 18),

                    // PASSWORD
                    _buildTextField(
                      hint: 'Password',
                      controller: _passwordController,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // CONFIRM PASSWORD
                    _buildTextField(
                      hint: 'Confirm Password',
                      controller: _confirmPasswordController,
                      isConfirmPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirm your password';
                        }
                        if (v != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // REMEMBER ME
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                        ),
                        Flexible(
                          child: Text(
                            'Remember me',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),

                    // CREATE ACCOUNT BUTTON
                    Center(
                      child: SizedBox(
                        width: 240,
                        height: 51,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [primaryColor, secondaryColor],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor: Colors.grey.shade400,
                              shadowColor: Colors.transparent,
                              shape: const StadiumBorder(),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Create an account',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // LOGIN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Already have an account? ',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
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
}

// PURPLE CURVED SHAPE: light back layer (mirrored from the login blob)
class PurpleBlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(w * 0.60, h * 0.30)
      ..cubicTo(w * 0.45, h * 0.50, w * 0.15, h * 0.62, 0, h * 0.55)
      ..lineTo(0, h * 0.90)
      ..cubicTo(w * 0.20, h * 0.95, w * 0.60, h * 0.85, w * 0.70, h * 0.60)
      ..cubicTo(w * 0.74, h * 0.48, w * 0.70, h * 0.38, w * 0.60, h * 0.30)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// PURPLE CURVED SHAPE: darker front layer at the top-left corner
class PurpleBlobDarkClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(w * 0.85, 0)
      ..lineTo(0, 0)
      ..lineTo(0, h * 0.55)
      ..cubicTo(w * 0.15, h * 0.62, w * 0.45, h * 0.50, w * 0.60, h * 0.30)
      ..cubicTo(w * 0.72, h * 0.14, w * 0.90, h * 0.10, w * 0.85, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}