import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Widget de decoração de fundo com círculos animados
/// Baseado no background-decoration do Angular
class BackgroundDecoration extends StatefulWidget {
  final Widget child;
  final bool showDecoration;

  const BackgroundDecoration({
    super.key,
    required this.child,
    this.showDecoration = true,
  });

  @override
  State<BackgroundDecoration> createState() => _BackgroundDecorationState();
}

class _BackgroundDecorationState extends State<BackgroundDecoration>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late AnimationController _controller4;

  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;
  late Animation<double> _animation4;

  @override
  void initState() {
    super.initState();

    // Controlador para circle-1 (20s)
    _controller1 = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    // Controlador para circle-2 (15s, reverso)
    _controller2 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    // Controlador para circle-3 (18s)
    _controller3 = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat(reverse: true);

    // Controlador para circle-4 (22s)
    _controller4 = AnimationController(
      duration: const Duration(seconds: 22),
      vsync: this,
    )..repeat(reverse: true);

    // Animações de float (translateY + rotate)
    _animation1 = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller1, curve: Curves.easeInOut),
    );

    _animation2 = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller2, curve: Curves.easeInOut),
    );

    _animation3 = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller3, curve: Curves.easeInOut),
    );

    _animation4 = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller4, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Background decorations
        if (widget.showDecoration) ...[
          // Circle 1 - Top Left
          Positioned(
            top: -100,
            left: -100,
            child: AnimatedBuilder(
              animation: _animation1,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation1.value),
                  child: Transform.rotate(
                    angle: _controller1.value * 0.0872665,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark ? [
                            AppColors.tertiaryColor.withAlpha(40),
                            AppColors.primaryButton.withAlpha(25),
                          ] : [
                            AppColors.primaryColor.withAlpha(20),
                            AppColors.primaryColor.withAlpha(10),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Circle 2 - Bottom Right
          Positioned(
            bottom: -80,
            right: -80,
            child: AnimatedBuilder(
              animation: _animation2,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation2.value),
                  child: Transform.rotate(
                    angle: -_controller2.value * 0.0872665,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark ? [
                            AppColors.tertiaryColor.withAlpha(45),
                            AppColors.primaryButton.withAlpha(30),
                          ] : [
                            AppColors.primaryButton.withAlpha(20),
                            AppColors.primaryButton.withAlpha(10),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Circle 3 - Middle Top Right
          AnimatedBuilder(
            animation: _animation3,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                right: MediaQuery.of(context).size.width * 0.05,
                child: Transform.translate(
                  offset: Offset(0, _animation3.value),
                  child: Transform.rotate(
                    angle: _controller3.value * 0.0872665,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark ? [
                            AppColors.tertiaryColor.withAlpha(35),
                            AppColors.primaryButton.withAlpha(25),
                          ] : [
                            AppColors.tertiaryColor.withAlpha(15),
                            AppColors.primaryButton.withAlpha(15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Circle 4 - Middle Bottom Left
          AnimatedBuilder(
            animation: _animation4,
            builder: (context, child) {
              return Positioned(
                bottom: MediaQuery.of(context).size.height * 0.12,
                left: MediaQuery.of(context).size.width * 0.05,
                child: Transform.translate(
                  offset: Offset(0, _animation4.value),
                  child: Transform.rotate(
                    angle: _controller4.value * 0.0872665,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark ? [
                            AppColors.tertiaryColor.withAlpha(40),
                            AppColors.primaryButton.withAlpha(28),
                          ] : [
                            AppColors.primaryColor.withAlpha(15),
                            AppColors.tertiaryColor.withAlpha(15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        widget.child,
      ],
    );
  }
}

