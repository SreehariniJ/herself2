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

void main() async {
  // Ensure Flutter is ready before we do anything
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load the database so the app is instant
  final prefs = await SharedPreferences.getInstance();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserState(prefs),
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
          seedColor: const Color(0xFFF48FB1),
          primary: const Color(0xFFAD1457),
          secondary: const Color(0xFF00897B),
          surface: const Color(0xFFFFF8F9),
        ),
        // Poppins is beautiful, but we use system fallback to avoid wait times
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const ReminderListener(child: HomeScreen()),
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
        title: Row(
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
              // Mark as done? Or just dismiss
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
