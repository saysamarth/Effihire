import 'package:flutter/material.dart';

class ProfileActionButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const ProfileActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  State<ProfileActionButton> createState() => _ProfileActionButtonState();
}

class _ProfileActionButtonState extends State<ProfileActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onPressed,
            icon: Icon(
              widget.icon,
              color: widget.textColor,
              size: 20,
            ),
            label: Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.textColor,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: widget.borderColor != null
                    ? BorderSide(color: widget.borderColor!, width: 1.5)
                    : BorderSide.none,
              ),
              elevation: widget.borderColor != null ? 0 : 2,
              shadowColor: widget.backgroundColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}