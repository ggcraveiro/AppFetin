import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';
import '../models/tree_model.dart';

class MyTreeCard extends StatefulWidget {
  final TreeModel tree;
  final Duration delay;

  const MyTreeCard({super.key, required this.tree, required this.delay});

  @override
  State<MyTreeCard> createState() => _MyTreeCardState();
}

class _MyTreeCardState extends State<MyTreeCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.translationValues(0, _pressed ? 0 : 0, 0)
              ..scale(_pressed ? 0.97 : 1.0),
            transformAlignment: Alignment.center,
            width: 158,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppColors.greenDark, AppColors.greenMid],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.greenLight.withOpacity(0.25)),
              boxShadow: _pressed
                  ? []
                  : [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.tree.emoji, style: const TextStyle(fontSize: 36)),
                    if (widget.tree.urgentDays != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.tree.urgentDays}d',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.tree.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                Text(widget.tree.location,
                  style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.55))),
                const SizedBox(height: 10),
                Text(
                  '💨 ${widget.tree.co2kg} kg CO₂',
                  style: const TextStyle(fontSize: 11, color: AppColors.greenPale, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: widget.tree.progress,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation(Colors.white70),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.tree.monthsPlanted} meses plantada',
                  style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
