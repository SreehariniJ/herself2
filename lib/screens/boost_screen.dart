import 'package:flutter/material.dart';
import 'health_care_screen.dart';
import 'dart:async';

class BoostScreen extends StatefulWidget {
  const BoostScreen({super.key});

  @override
  State<BoostScreen> createState() => _BoostScreenState();
}

class _BoostScreenState extends State<BoostScreen> {
  // Demo Variables
  double _energyLevel = 4;
  String _selectedMood = 'stressed';

  final List<String> _moods = ['tired', 'stressed', 'sad', 'happy', 'anxious'];

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

  List<Map<String, dynamic>> _getBoostActivities(int energy, String mood) {
    if (energy <= 3) {
      if (mood == 'tired') {
        return [
          {'title': 'Breathing', 'desc': 'Deep breaths', 'icon': Icons.air, 'color': Colors.blue, 'action': () => _showTimer(context, 'Breathing', 1)},
          {'title': 'Drink Water', 'desc': 'Hydrate now', 'icon': Icons.water_drop, 'color': Colors.cyan, 'action': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthCareScreen()))},
          {'title': 'Rest 1 Min', 'desc': 'Close eyes', 'icon': Icons.bed, 'color': Colors.indigo, 'action': () => _showTimer(context, 'Resting', 1)},
        ];
      }
      if (mood == 'stressed') {
        return [
          {'title': 'Breathing', 'desc': 'Calm down', 'icon': Icons.air, 'color': Colors.blue, 'action': () => _showTimer(context, 'Breathing', 3)},
          {'title': 'Write Worry', 'desc': 'Journal it', 'icon': Icons.edit, 'color': Colors.orange, 'action': () {}},
          {'title': 'Relax Eyes', 'desc': 'Look away', 'icon': Icons.visibility_off, 'color': Colors.green, 'action': () => _showTimer(context, 'Eye Relaxation', 1)},
        ];
      }
      if (mood == 'sad') {
        return [
          {'title': 'Play Music', 'desc': 'Uplifting tunes', 'icon': Icons.music_note, 'color': Colors.pink, 'action': () {}},
          {'title': 'Text Friend', 'desc': 'Reach out', 'icon': Icons.chat, 'color': Colors.purple, 'action': () {}},
          {'title': 'Step Outside', 'desc': 'Fresh air', 'icon': Icons.nature, 'color': Colors.green, 'action': () {}},
        ];
      }
    } else if (energy >= 4 && energy <= 6) {
      if (mood == 'stressed') {
        return [
          {'title': '5-Min Focus', 'desc': 'Single task', 'icon': Icons.timer, 'color': Colors.blue, 'action': () => _showTimer(context, 'Focus Session', 5)},
          {'title': 'Break Task', 'desc': 'Small steps', 'icon': Icons.list, 'color': Colors.orange, 'action': () {}},
          {'title': 'Planner', 'desc': 'Organize', 'icon': Icons.calendar_today, 'color': Colors.teal, 'action': () {}}, // Navigate to planner if strictly needed
        ];
      }
      if (mood == 'tired') {
        return [
          {'title': 'Stretch', 'desc': 'Move body', 'icon': Icons.accessibility_new, 'color': Colors.purple, 'action': () => _showTimer(context, 'Stretching', 3)},
          {'title': 'Move', 'desc': 'Walk around', 'icon': Icons.directions_walk, 'color': Colors.green, 'action': () => _showTimer(context, 'Walking', 5)},
          {'title': 'Easy Task', 'desc': 'Quick win', 'icon': Icons.check_circle, 'color': Colors.blue, 'action': () {}},
        ];
      }
      if (mood == 'happy') {
        return [
          {'title': 'Priority Task', 'desc': 'Do it now', 'icon': Icons.star, 'color': Colors.amber, 'action': () {}},
          {'title': 'Review Goals', 'desc': 'Think big', 'icon': Icons.flag, 'color': Colors.red, 'action': () {}},
          {'title': 'Share Joy', 'desc': 'Tell someone', 'icon': Icons.share, 'color': Colors.pink, 'action': () {}},
        ];
      }
    } else { // energy >= 7
      if (mood == 'happy') {
         return [
          {'title': 'Deep Work', 'desc': '25 min focus', 'icon': Icons.work, 'color': Colors.deepPurple, 'action': () => _showTimer(context, 'Deep Work', 25)},
          {'title': 'Workout', 'desc': 'Burn energy', 'icon': Icons.fitness_center, 'color': Colors.red, 'action': () {}},
          {'title': 'Learn New', 'desc': 'Read/Study', 'icon': Icons.book, 'color': Colors.blue, 'action': () {}},
        ];
      }
      if (mood == 'anxious') {
        return [
          {'title': 'Structured Plan', 'desc': 'Write plan', 'icon': Icons.format_list_numbered, 'color': Colors.teal, 'action': () {}},
          {'title': 'Checklist', 'desc': 'Tick off', 'icon': Icons.check_box, 'color': Colors.green, 'action': () {}},
          {'title': 'Organize', 'desc': 'Clean space', 'icon': Icons.cleaning_services, 'color': Colors.orange, 'action': () {}},
        ];
      }
    }
    
    // Fallback default
    return [
      {'title': 'Breathe', 'desc': 'Just breathe', 'icon': Icons.air, 'color': Colors.blue, 'action': () => _showTimer(context, 'Breathing', 2)},
      {'title': 'Stretch', 'desc': 'Loosen up', 'icon': Icons.accessibility, 'color': Colors.purple, 'action': () => _showTimer(context, 'Stretching', 3)},
      {'title': 'Hydrate', 'desc': 'Drink water', 'icon': Icons.water_drop, 'color': Colors.cyan, 'action': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthCareScreen()))},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activities = _getBoostActivities(_energyLevel.round(), _selectedMood);

    return Scaffold(
      appBar: AppBar(title: const Text('Boost')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls Section (Demo)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("How are you feeling?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: _moods.map((m) => ChoiceChip(
                      label: Text(m.capitalize()),
                      selected: _selectedMood == m,
                      selectedColor: Colors.orange.shade200,
                      onSelected: (val) => setState(() => _selectedMood = m),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Energy Level", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${_energyLevel.round()}/10", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 18)),
                    ],
                  ),
                  Slider(
                    value: _energyLevel,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: Colors.orange,
                    onChanged: (val) => setState(() => _energyLevel = val),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Dynamic Suggestions
            Text(
              'Recommended for You',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) => _buildBoosterItem(
              context,
              activity['title'],
              activity['desc'],
              activity['icon'],
              activity['color'],
              activity['action'],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBoosterItem(BuildContext context, String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 24,
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(desc),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.play_arrow, size: 20, color: Colors.black54),
        ),
      ),
    );
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}
