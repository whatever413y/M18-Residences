import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  final double textTopOffset;
  const LoadingOverlay({super.key, this.textTopOffset = 300.0});

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

    _dotsController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final maxTextWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.8;

    return Container(
      color: Colors.white.withValues(alpha: 0.3),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.textTopOffset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    opacity: showMessage ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: AnimatedBuilder(
                      animation: _dotsAnimation,
                      builder:
                          (context, _) => ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxTextWidth),
                            child: Text(
                              "Server taking too long to respond, please wait a moment${_buildDots()}",
                              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(child: const CircularProgressIndicator()),
        ],
      ),
    );
  }
}
