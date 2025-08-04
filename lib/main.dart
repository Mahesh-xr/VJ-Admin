import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vayujal/firebase_options.dart';
import 'package:vayujal/screens/service_personel_screen.dart';
import 'package:vayujal/screens/splash_screen.dart';
import 'package:vayujal/screens/dashboard_screen.dart';
import 'package:vayujal/screens/all_devices.dart';
import 'package:vayujal/screens/admin_profile.dart';
import 'package:vayujal/screens/service_hostory_screen.dart';
import 'package:vayujal/screens/notification_page.dart';
import 'package:vayujal/utils/performance_utils.dart';
import 'package:vayujal/services/push_notification_service.dart';
import 'package:vayujal/services/local_notification_service.dart';
import 'package:vayujal/services/auth.dart';
import 'package:vayujal/screens/all_service_request_page.dart';
import 'package:vayujal/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local notifications
  await LocalNotificationService.initialize();
  
  // Initialize FCM and save token on app start
  await PushNotificationService.initialize();

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

  // Performance optimizations
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Reduce frame time for better performance
  const double targetFrameRate = 60.0;
  const double frameTime = 1000.0 / targetFrameRate;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vayujal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Optimize performance with these settings
        useMaterial3: true,
        // Reduce animation duration for better performance
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        // Performance optimizations
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        // Optimize text rendering
        textTheme: const TextTheme().apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
      ),
      home: const AuthWrapper(),
      // Define routes for navigation
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/alldevice': (context) => const DevicesScreen(),
        '/profile': (context) => ServicePersonnelPage(),
        '/history': (context) => const AllServiceRequestsPage(),
        '/notifications': (context) => const NotificationPage(),
        '/login': (context) => const LoginScreen(),
      },
      // Add performance optimizations
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Optimize text scaling
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
          ),
          child: child!,
        );
      },
    );
  }
}
