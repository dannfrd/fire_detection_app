import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/fire_detection_provider.dart';
import 'screens/main_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FireDetectionProvider(),
      child: MaterialApp(
        title: 'Agrotech Fire Detection',
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
