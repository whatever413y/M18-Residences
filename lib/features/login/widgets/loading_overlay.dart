import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({super.key});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> with SingleTickerProviderStateMixin {
  bool showMessage = false;
  late AnimationController _dotsController;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => showMessage = true);
      }
    });

    _dotsController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: false);

    _dotsAnimation = Tween<double>(begin: 0, end: 3).animate(_dotsController);
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  String _buildDots() {
    int dotsCount = _dotsAnimation.value.floor();
    return '.' * dotsCount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(padding: const EdgeInsets.all(16), child: const CircularProgressIndicator()),
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: showMessage ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedBuilder(
                animation: _dotsAnimation,
                builder:
                    (context, _) => Text(
                      "Server is starting, please wait${_buildDots()}",
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
