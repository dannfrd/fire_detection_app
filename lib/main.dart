import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/fire_detection_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable verbose logging in debug mode
  bool isDebug = false;
  assert(() {
    isDebug = true;
    return true;
  }());

  // Print platform information for debugging
  if (isDebug) {
    print('Running in debug mode');
  } else {
    print('Running in release mode');
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FireDetectionSettings()),
        ChangeNotifierProxyProvider<FireDetectionSettings,
            FireDetectionProvider>(
          create: (context) => FireDetectionProvider(),
          update: (context, settings, previous) {
            final provider = previous ?? FireDetectionProvider();
            provider.setSettingsProvider(settings);
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Agrotech Fire Detection',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
