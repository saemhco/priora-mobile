import 'package:flutter/material.dart';

/// Wraps [child] with a pulsing opacity "shimmer" animation used by all
/// loading skeletons across the app (shared/reusable widget).
class Shimmer extends StatefulWidget {
  const Shimmer({
    required this.child, super.key,
    this.duration = const Duration(milliseconds: 1200),
    this.begin = 0.35,
    this.end = 0.85,
  });

  final Widget child;
  final Duration duration;
  final double begin;
  final double end;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: widget.begin, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: child);
      },
      child: widget.child,
    );
  }
}
