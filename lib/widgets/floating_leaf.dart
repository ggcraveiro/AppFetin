import 'package:flutter/material.dart';

class FloatingLeaf extends StatefulWidget {
  final String emoji;
  final double leftFraction;
  final Duration delay;
  final double size;

  const FloatingLeaf({
    super.key,
    required this.emoji,
    required this.leftFraction,
    required this.delay,
    this.size = 18,
  });

  @override
  State<FloatingLeaf> createState() => _FloatingLeafState();
}

class _FloatingLeafState extends State<FloatingLeaf> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _posY;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.2), weight: 20),
      TweenSequenceItem(tween: ConstantTween(0.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 0.0), weight: 20),
    ]).animate(_ctrl);

    _posY = Tween<double>(begin: 1.0, end: -0.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );

    _rotate = Tween<double>(begin: 0, end: 0.7).animate(_ctrl);

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final screenH = constraints.maxHeight > 0 ? constraints.maxHeight : 200.0;
            return Positioned(
              left: widget.leftFraction * (constraints.maxWidth > 0 ? constraints.maxWidth : 300),
              top: _posY.value * screenH,
              child: Opacity(
                opacity: _opacity.value,
                child: Transform.rotate(
                  angle: _rotate.value,
                  child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
