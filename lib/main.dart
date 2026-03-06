import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/folders_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for a polished status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  const CardOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      home: const FoldersScreen(),
    );
  }
}
