import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Avatar size presets
enum AvatarSize {
  xs(24),
  sm(32),
  md(48),
  lg(64),
  xl(96);

  final double value;
  const AvatarSize(this.value);
}

/// Modern Avatar Widget - Beautiful, animated user avatars
class ModernAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final AvatarSize size;
  final int? gradientIndex;
  final bool showOnlineIndicator;
  final bool isOnline;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final bool animate;

  const ModernAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = AvatarSize.md,
    this.gradientIndex,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = gradientIndex != null 
        ? _getGradientColor(gradientIndex!)
        : AppColors.getAvatarColor(name);
    final initials = _getInitials(name);
    final sizeValue = size.value;
    final fontSize = sizeValue * 0.38;

    Widget avatar = GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizeValue,
        height: sizeValue,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              avatarColor.withValues(alpha: 0.9),
              avatarColor,
            ],
          ),
          border: showBorder
              ? Border.all(
                  color: borderColor ?? Colors.white,
                  width: sizeValue * 0.06,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: avatarColor.withValues(alpha: 0.3),
              blurRadius: sizeValue * 0.3,
              offset: Offset(0, sizeValue * 0.1),
            ),
          ],
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildInitials(initials, fontSize),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildInitials(initials, fontSize);
                  },
                )
              : _buildInitials(initials, fontSize),
        ),
      ),
    );

    if (showOnlineIndicator) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: sizeValue * 0.02,
            bottom: sizeValue * 0.02,
            child: Container(
              width: sizeValue * 0.28,
              height: sizeValue * 0.28,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : AppColors.lightTextMuted,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: sizeValue * 0.05,
                ),
                boxShadow: isOnline
                    ? [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      );
    }

    if (animate) {
      return avatar.animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            curve: Curves.easeOutBack,
            duration: 400.ms,
          );
    }

    return avatar;
  }

  Color _getGradientColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.purple,
      AppColors.cyan,
      AppColors.warning,
      AppColors.success,
      AppColors.error,
    ];
    return colors[index % colors.length];
  }

  Widget _buildInitials(String initials, double fontSize) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

/// Avatar Group - Shows multiple avatars stacked
class AvatarGroup extends StatelessWidget {
  final List<AvatarData> avatars;
  final AvatarSize size;
  final int maxDisplay;
  final double overlap;

  const AvatarGroup({
    super.key,
    required this.avatars,
    this.size = AvatarSize.sm,
    this.maxDisplay = 4,
    this.overlap = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = avatars.length > maxDisplay ? maxDisplay : avatars.length;
    final remaining = avatars.length - maxDisplay;
    final sizeValue = size.value;

    return SizedBox(
      width: sizeValue + (displayCount - 1) * sizeValue * (1 - overlap) + (remaining > 0 ? sizeValue * (1 - overlap) : 0),
      height: sizeValue,
      child: Stack(
        children: [
          for (int i = displayCount - 1; i >= 0; i--)
            Positioned(
              left: i * sizeValue * (1 - overlap),
              child: ModernAvatar(
                name: avatars[i].name,
                imageUrl: avatars[i].imageUrl,
                size: size,
                showBorder: true,
                animate: false,
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: displayCount * sizeValue * (1 - overlap),
              child: Container(
                width: sizeValue,
                height: sizeValue,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sizeValue * 0.32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AvatarData {
  final String name;
  final String? imageUrl;

  const AvatarData({required this.name, this.imageUrl});
}
