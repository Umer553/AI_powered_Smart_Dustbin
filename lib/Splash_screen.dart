import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Navigate to SignupScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignupScreen()),
      );
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A0F2C), Color(0xFF2E1A47)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          // Floating Particles
          CustomPaint(
            painter: ParticlePainter(_particleController.value),
            child: Container(),
          ),
          // Center Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Icon
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.1).animate(
                    CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.7),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_forever,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Animated Gradient Text
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.cyanAccent,
                            Colors.white,
                            Colors.greenAccent
                          ],
                          stops: [
                            _textController.value * 0.5,
                            0.5,
                            1 - _textController.value * 0.5
                          ],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        "AI Powered\nSmart Dustbin",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),
                // Pulsating Dots Loader
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        double scale = 0.5 + 0.5 *
                            (sin((index + _textController.value * 2 * pi)) * 0.5 + 0.5);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Particle Painter
class ParticlePainter extends CustomPainter {
  final double progress;
  final Random random = Random();

  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.cyanAccent.withOpacity(0.3);

    for (int i = 0; i < 50; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = (random.nextDouble() * size.height + progress * size.height) % size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
