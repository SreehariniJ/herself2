import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/herself_core.dart';

class HealthCareScreen extends StatelessWidget {
  const HealthCareScreen({super.key});

  void _showSleepDialog(BuildContext context, UserState state) {
    int localSleep = state.sleepHours;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Sleep Log'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How many hours did you sleep?', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setDialogState(() => localSleep > 0 ? localSleep-- : null),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$localSleep h', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => setDialogState(() => localSleep < 24 ? localSleep++ : null),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                state.updateSleep(localSleep);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCycleInfo(BuildContext context, UserState state) {
    int localDays = state.daysUntilCycle;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cycle Tracker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month, size: 50, color: Colors.pink),
              const SizedBox(height: 16),
              const Text(
                'Days until next cycle:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setDialogState(() => localDays > 0 ? localDays-- : null),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$localDays', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pink)),
                  IconButton(
                    onPressed: () => setDialogState(() => localDays < 40 ? localDays++ : null),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    state.resetCycle();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('Period Started Today'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.pink),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                state.updateCycleDays(localDays);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _startMeditation(BuildContext context, UserState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.self_improvement, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            const Text('Meditation Session', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Take a deep breath and clear your mind...', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.teal),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                state.addMeditationMinutes(5);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              child: const Text('End Session'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Health Care')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Hydration Tracker',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${userState.waterCups} / 8 cups today',
                    style: TextStyle(fontSize: 24, color: Colors.blue[900], fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: userState.waterCups / 8,
                    backgroundColor: Colors.blue[100],
                    color: Colors.blue,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Provider.of<UserState>(context, listen: false).incrementWater(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Cup'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => Provider.of<UserState>(context, listen: false).resetWater(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildHealthTile(
              'Cycle Tracker',
              'Next cycle in ${userState.daysUntilCycle} days',
              Icons.calendar_month,
              Colors.pink,
              () => _showCycleInfo(context, userState),
            ),
            _buildHealthTile(
              'Sleep Log',
              '${userState.sleepHours}h recorded last night',
              Icons.bedtime,
              Colors.deepPurple,
              () => _showSleepDialog(context, userState),
            ),
            _buildHealthTile(
              'Meditation',
              '${userState.meditationMinutes} mins completed today',
              Icons.self_improvement,
              Colors.teal,
              () => _startMeditation(context, userState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTile(String title, String status, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(status),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
