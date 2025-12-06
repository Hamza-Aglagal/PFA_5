import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/connectivity_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check connectivity
    setState(() => _statusMessage = 'Checking connection...');
    final connectivity = context.read<ConnectivityService>();
    await connectivity.init();
    
    // Wait for animations to start
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() => _statusMessage = 'Loading your data...');
    
    // Load notifications
    final notificationService = context.read<NotificationService>();
    await notificationService.loadNotifications();
    
    // Wait for remaining animations
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final authService = context.read<AuthService>();
    final storageService = context.read<StorageService>();

    // Check onboarding status
    final onboardingComplete = await storageService.isOnboardingComplete();

    if (!mounted) return;

    if (!onboardingComplete) {
      context.go('/onboarding');
    } else if (authService.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Logo Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Iconsax.building_35,
                    size: 64,
                    color: AppColors.primary,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                // App Name
                Text(
                  'SimStruct',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, duration: 500.ms),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'AI-Powered Structural Analysis',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, duration: 500.ms),

                const Spacer(flex: 2),
                
                // Status Message
                Text(
                  _statusMessage,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white60,
                  ),
                ).animate().fadeIn(delay: 700.ms),
                
                const SizedBox(height: 16),

                // Loading indicator
                SizedBox(
                  width: 28,
                  height: 28,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ).animate(delay: 800.ms).fadeIn(duration: 300.ms),
                
                const SizedBox(height: 60),
                
                // Version
                Text(
                  'v1.0.0',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ).animate(delay: 900.ms).fadeIn(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
