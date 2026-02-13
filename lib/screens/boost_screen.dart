import 'package:flutter/material.dart';
import 'health_care_screen.dart';
import 'dart:async';

class BoostScreen extends StatelessWidget {
  const BoostScreen({super.key});

  void _showTimer(BuildContext context, String title, int minutes) {
    int total = minutes * 60;
    int remaining = total;
    Timer? timer;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (remaining > 0) {
              if (context.mounted) {
                setDialogState(() => remaining--);
              }
            } else {
              t.cancel();
            }
          });

          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: remaining / total,
                        strokeWidth: 8,
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Keep going, you got this!', style: TextStyle(color: Colors.grey)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  timer?.cancel();
                  Navigator.pop(context);
                },
                child: const Text('Stop'),
              ),
            ],
          );
        },
      ),
    ).then((_) => timer?.cancel());
  }

  @override
  Widget build(BuildContext context) {
    final quotes = [
      "Believe you can and you're halfway there.",
      "You are stronger than you know.",
      "Self-care is not a luxury, it's a necessity.",
      "Your speed doesn't matter, forward is forward.",
      "Radiate positivity and the world will reflect it."
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Boost')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Motivation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: quotes.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrangeAccent]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        '"${quotes[index]}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Quick Boosters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildBoosterItem(
              context,
              'Drink Water',
              'Stay hydrated for better focus',
              Icons.water_drop,
              Colors.blue,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthCareScreen())),
            ),
            _buildBoosterItem(
              context,
              '5-Min Walk',
              'Fresh air resets the mind',
              Icons.directions_walk,
              Colors.green,
              () => _showTimer(context, 'Walking Session', 5),
            ),
            _buildBoosterItem(
              context,
              'Stretch',
              'Release physical tension',
              Icons.accessibility_new,
              Colors.purple,
              () => _showTimer(context, 'Stretching Session', 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoosterItem(BuildContext context, String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
