
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';


const kPurpleDark = Color(0xFF4A0A7A);
const kPurpleText = Color(0xFF6A2C9A);
const kBackground = Color(0xFFF7F5FC);
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // Decorative blobs, bottom right
          Positioned.fill(
            child: CustomPaint(painter: BlobPainter()),
          ),
 
          // Small accent dot
          Positioned(
            left: 12,
            top: MediaQuery.of(context).size.height * 0.34,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFD81B60),
                shape: BoxShape.circle,
              ),
            ),
          ),
 
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 56),
                  // Logo + app name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5A0C94),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.layers_outlined,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'FlowTask',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2B2B2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 5),
                  Text(
                    'Welcome !',
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: kPurpleDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'We’re glad you’re here.\nlet’s get started.',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      height: 1.4,
                      color: kPurpleText,
                    ),
                  ),
                  const Spacer(flex: 5),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurpleDark,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: kPurpleDark.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'GET STARTED',
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
class BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
 
    // Large, light blob
    final light = Path()
      ..moveTo(w * 0.92, h * 0.52)
      ..cubicTo(w * 1.02, h * 0.54, w * 1.05, h * 0.60, w * 1.05, h * 0.65)
      ..lineTo(w * 1.05, h * 1.02)
      ..lineTo(w * 0.60, h * 1.02)
      ..cubicTo(w * 0.62, h * 0.90, w * 0.70, h * 0.84, w * 0.75, h * 0.78)
      ..cubicTo(w * 0.82, h * 0.70, w * 0.78, h * 0.60, w * 0.92, h * 0.52)
      ..close();
    canvas.drawPath(light, Paint()..color = const Color(0xFFE6D3F2));
 
    // Smaller, darker blob
    final dark = Path()
      ..moveTo(w * 0.90, h * 0.68)
      ..cubicTo(w * 1.00, h * 0.70, w * 1.05, h * 0.74, w * 1.05, h * 0.78)
      ..lineTo(w * 1.05, h * 1.02)
      ..lineTo(w * 0.72, h * 1.02)
      ..cubicTo(w * 0.74, h * 0.92, w * 0.78, h * 0.88, w * 0.80, h * 0.82)
      ..cubicTo(w * 0.83, h * 0.74, w * 0.82, h * 0.72, w * 0.90, h * 0.68)
      ..close();
    canvas.drawPath(dark, Paint()..color = const Color(0xFFD7B5EA));
  }
 
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
 