import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'core/herself_core.dart';
import 'core/notification_service.dart';
import 'core/auth_service.dart';
import 'core/database_helper.dart';
import 'screens/login_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

void main() async {
  // Ensure Flutter is ready before we do anything
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for Windows/Desktop (Skip on Web)
  // We use a try-catch because explicitly accessing Platform on web can throw error even inside an if check in some runtimes
  if (!kIsWeb) {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } catch (e) {
      // Ignore platform errors
    }
  }

  // Pre-load the database so the app is instant
  final prefs = await SharedPreferences.getInstance();

  // Initialize the SQLite database
  final dbHelper = DatabaseHelper();
  // dbHelper.init(prefs) is no longer needed with sqflite

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService(prefs, dbHelper)),
        ChangeNotifierProvider(create: (context) => UserState(prefs)),
      ],
      child: const HerselfApp(),
    ),
  );
}

class HerselfApp extends StatelessWidget {
  const HerselfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HERSELF',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C27B0), // Rich Purple
          primary: const Color(0xFF7B1FA2),
          secondary: const Color(0xFF00B8D4), // Elegant Cyan
          surface: const Color(0xFFFDFBFF),
        ),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 1.5),
          ),
        ),
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          if (authService.isAuthenticated) {
            return const ReminderListener(child: HomeScreen());
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

class ReminderListener extends StatefulWidget {
  final Widget child;
  const ReminderListener({super.key, required this.child});

  @override
  State<ReminderListener> createState() => _ReminderListenerState();
}

class _ReminderListenerState extends State<ReminderListener> {
  late StreamSubscription<TaskItem> _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = Provider.of<UserState>(context, listen: false);
      _subscription = userState.reminderStream.listen(_showReminder);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _showReminder(TaskItem task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.alarm, color: Colors.teal),
            SizedBox(width: 8),
            Text("Reminder"),
          ],
        ),
        content: Text("It's time for: ${task.title}"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Got it"),
          ),
        ],
      ),
    );
    // Try to vibrate if on mobile
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
