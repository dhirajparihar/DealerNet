import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56), // 8px grid
          side: BorderSide(
            color: backgroundColor ?? AppColors.borderDark,
            width: 1.0, // Crisp 1px
          ),
          foregroundColor: textColor ?? AppColors.textPrimary,
        ),
        child: _buildChild(context, textColor ?? AppColors.textPrimary),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56), // 8px grid
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? AppColors.textOnPrimary,
      ),
      child: _buildChild(context, textColor ?? AppColors.textOnPrimary),
    );
  }

  Widget _buildChild(BuildContext context, Color contentColor) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: contentColor),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: contentColor, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      );
    }

    return Text(label, style: TextStyle(color: contentColor, fontSize: 16, fontWeight: FontWeight.w600));
  }
}
