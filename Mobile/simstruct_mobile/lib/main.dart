import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app/theme/app_theme.dart';
import 'app/router/app_router.dart';
import 'core/services/services.dart';
import 'shared/widgets/app_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  
  final connectivityService = ConnectivityService();

  runApp(
    SimStructApp(
      storageService: storageService,
      connectivityService: connectivityService,
    ),
  );
}

class SimStructApp extends StatelessWidget {
  final StorageService storageService;
  final ConnectivityService connectivityService;

  const SimStructApp({
    super.key,
    required this.storageService,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Storage Service
        Provider<StorageService>.value(value: storageService),
        
        // Connectivity Service
        ChangeNotifierProvider<ConnectivityService>.value(value: connectivityService),
        
        // Auth Service
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService()..init(),
        ),
        
        // Notification Service
        ChangeNotifierProvider<NotificationService>(
          create: (_) => NotificationService(),
        ),
        
        // Simulation Service
        ChangeNotifierProxyProvider<AuthService, SimulationService>(
          create: (_) => SimulationService(),
          update: (_, authService, simulationService) {
            if (authService.user != null && simulationService != null) {
              simulationService.loadSimulations(authService.user!.id);
            }
            return simulationService ?? SimulationService();
          },
        ),
        
        // Community Service
        ChangeNotifierProxyProvider<AuthService, CommunityService>(
          create: (_) => CommunityService(),
          update: (_, authService, communityService) {
            if (authService.user != null && communityService != null) {
              // Load community data when user is available
            }
            return communityService ?? CommunityService();
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router;
          
          return MaterialApp.router(
            title: 'SimStruct',
            debugShowCheckedModeBanner: false,
            
            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            
            // Router configuration
            routerConfig: router,
            
            // Builder for global overlays
            builder: (context, child) {
              // Apply proper text scaling
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: GestureDetector(
                  // Dismiss keyboard on tap outside
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: AppWrapper(
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
