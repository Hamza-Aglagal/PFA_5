import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simstruct_mobile/core/services/auth_service.dart';
import 'package:simstruct_mobile/core/services/notification_service.dart';
import 'mocks.dart';

/// Creates a testable MaterialApp wrapper
Widget createTestableWidget({
  required Widget child,
  MockAuthService? authService,
  MockNotificationService? notificationService,
}) {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(
          value: authService ?? MockAuthService(),
        ),
        ChangeNotifierProvider<NotificationService>.value(
          value: notificationService ?? MockNotificationService(),
        ),
      ],
      child: Scaffold(body: child),
    ),
  );
}

/// Creates a simple MaterialApp wrapper without providers
Widget createSimpleTestableWidget({required Widget child}) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 600,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Creates a themed MaterialApp wrapper
Widget createThemedTestableWidget(Widget child, {bool isDark = false}) {
  return MaterialApp(
    theme: isDark ? ThemeData.dark() : ThemeData.light(),
    home: Scaffold(body: child),
  );
}

/// Test navigation observer
class TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }
}
