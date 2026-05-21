import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';
import '../models/tree_model.dart';

class AdoptTreeCardWidget extends StatefulWidget {
  final AdoptTreeModel tree;
  final Duration delay;
  final VoidCallback onAdopt;

  const AdoptTreeCardWidget({
    super.key,
    required this.tree,
    required this.delay,
    required this.onAdopt,
  });

  @override
  State<AdoptTreeCardWidget> createState() => _AdoptTreeCardWidgetState();
}

class _AdoptTreeCardWidgetState extends State<AdoptTreeCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
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
          onTapDown: (_) => setState(() => _hovered = true),
          onTapUp: (_) => setState(() => _hovered = false),
          onTapCancel: () => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greenDark,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _hovered ? AppColors.greenLight : AppColors.greenMain.withOpacity(0.3),
              ),
              boxShadow: _hovered
                  ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))]
                  : [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.greenMid, AppColors.greenMain],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(widget.tree.emoji, style: const TextStyle(fontSize: 30))),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.tree.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.greenMist)),
                      Text(widget.tree.species,
                        style: const TextStyle(fontSize: 10, color: AppColors.greenLight, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5, runSpacing: 4,
                        children: [
                          ...widget.tree.tags.map((tag) => _tag(tag, false)),
                          if (widget.tree.isEndangered) _tag('🔴 Ameaçada', true),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Price + button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${widget.tree.priceMonthly.toStringAsFixed(0)}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15, color: AppColors.gold, fontWeight: FontWeight.w700),
                    ),
                    Text('/mês', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.4))),
                    const SizedBox(height: 7),
                    _AdoptButton(adopted: widget.tree.adopted, onTap: widget.onAdopt),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, bool isThreaten) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isThreaten ? AppColors.coral.withOpacity(0.2) : AppColors.greenLight.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isThreaten ? AppColors.coral.withOpacity(0.35) : AppColors.greenLight.withOpacity(0.22),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9, fontWeight: FontWeight.w600,
          color: isThreaten ? AppColors.coral : AppColors.greenPale,
        ),
      ),
    );
  }
}

class _AdoptButton extends StatefulWidget {
  final bool adopted;
  final VoidCallback onTap;
  const _AdoptButton({required this.adopted, required this.onTap});

  @override
  State<_AdoptButton> createState() => _AdoptButtonState();
}

class _AdoptButtonState extends State<_AdoptButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.9);
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.adopted) return;
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.93).animate(_ctrl),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: widget.adopted ? const Color(0xFF2d6a4f) : AppColors.greenLight,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            widget.adopted ? '✓ Adotada!' : 'Adotar',
            style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
