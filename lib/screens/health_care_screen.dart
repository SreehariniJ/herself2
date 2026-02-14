import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/herself_core.dart';
import 'workout_screen.dart';

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
              Text(
                'How many hours did you sleep?',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setDialogState(
                      () => localSleep > 0 ? localSleep-- : null,
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$localSleep h',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setDialogState(
                      () => localSleep < 24 ? localSleep++ : null,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
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

  void _showCycleTracker(BuildContext context, UserState state) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CycleTrackerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final recentLogs = userState.getRecentLogs(7);
    final avgWater = userState.getAverageWater();
    final avgSleep = userState.getAverageSleep();
    final insight = userState.getHealthInsight();

    return Scaffold(
      appBar: AppBar(title: const Text('Health Care')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Hydration Tracker
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
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w900,
                    ),
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
                        onPressed: () => Provider.of<UserState>(
                          context,
                          listen: false,
                        ).incrementWater(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Cup'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => Provider.of<UserState>(
                          context,
                          listen: false,
                        ).resetWater(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // -- Health Insights Card --
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFF388E3C), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Health Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildAvgChip(
                        '💧 ${avgWater.toStringAsFixed(1)}',
                        'cups/day',
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildAvgChip(
                        '😴 ${avgSleep.toStringAsFixed(1)}',
                        'hrs/night',
                        Colors.deepPurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      insight,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // -- 7-Day History Chart --
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '7-Day History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Water (blue) & Sleep (purple)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 140,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: recentLogs.map((log) {
                        final dayLabel = log.date.length >= 10
                            ? DateFormat('E').format(DateTime.parse(log.date))
                            : '?';
                        final waterH = (log.waterCups / 10.0).clamp(0.0, 1.0);
                        final sleepH = (log.sleepHours / 12.0).clamp(0.0, 1.0);
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 100 * waterH + 4,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Container(
                                    width: 12,
                                    height: 100 * sleepH + 4,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade300,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dayLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Existing tiles
            _buildHealthTile(
              'Cycle Tracker',
              userState.lastPeriodDate != null
                  ? (userState.isOnPeriod()
                        ? 'Day ${userState.getCurrentPeriodDay()} of period'
                        : 'Next period in ${userState.getDaysUntilNextPeriod()} days')
                  : 'Tap to set up tracking',
              Icons.calendar_month,
              Colors.pink,
              () => _showCycleTracker(context, userState),
            ),
            _buildHealthTile(
              'Sleep Log',
              '${userState.sleepHours}h recorded last night',
              Icons.bedtime,
              Colors.deepPurple,
              () => _showSleepDialog(context, userState),
            ),
            _buildHealthTile(
              'Workout Plan',
              userState.getCyclePhase() != 'unknown'
                  ? '${_phaseEmoji(userState.getCyclePhase())} ${_phaseName(userState.getCyclePhase())} — tap to start'
                  : 'Personalized daily workout',
              Icons.fitness_center,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkoutScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvgChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  String _phaseEmoji(String phase) {
    switch (phase) {
      case 'menstrual': return '🌸';
      case 'follicular': return '🌱';
      case 'ovulatory': return '⚡';
      case 'luteal': return '🧘';
      default: return '💪';
    }
  }

  String _phaseName(String phase) {
    switch (phase) {
      case 'menstrual': return 'Menstrual Phase';
      case 'follicular': return 'Follicular Phase';
      case 'ovulatory': return 'Ovulatory Phase';
      case 'luteal': return 'Luteal Phase';
      default: return 'General';
    }
  }

  Widget _buildHealthTile(
    String title,
    String status,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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

class CycleTrackerScreen extends StatefulWidget {
  const CycleTrackerScreen({super.key});

  @override
  State<CycleTrackerScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends State<CycleTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = Provider.of<UserState>(context, listen: false);
      if (userState.lastPeriodDate == null) {
        _showInitialSetupDialog(context, userState);
      }
    });
  }

  void _showInitialSetupDialog(BuildContext context, UserState state) {
    DateTime? selectedDate;
    int cycleLength = 28;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.pink),
              SizedBox(width: 12),
              Text('Set Up Cycle Tracker'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'When was your last period?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 60),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.event),
                  label: Text(
                    selectedDate != null
                        ? DateFormat('MMM d, yyyy').format(selectedDate!)
                        : 'Select Date',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.pink,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'What is your average cycle length?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => setDialogState(
                        () => cycleLength > 21 ? cycleLength-- : null,
                      ),
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.pink,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$cycleLength days',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setDialogState(
                        () => cycleLength < 45 ? cycleLength++ : null,
                      ),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Typical range: 21-35 days',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: selectedDate == null
                  ? null
                  : () {
                      state.updateLastPeriodDate(selectedDate!);
                      state.updateCycleLength(cycleLength);
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectLastPeriodDate(
    BuildContext context,
    UserState state,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.lastPeriodDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      state.updateLastPeriodDate(picked);
    }
  }

  void _showSettingsDialog(BuildContext context, UserState state) {
    int localCycleLength = state.cycleLength;
    int localPeriodDuration = state.periodDuration;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cycle Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cycle Length (days)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setDialogState(
                      () => localCycleLength > 21 ? localCycleLength-- : null,
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$localCycleLength',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setDialogState(
                      () => localCycleLength < 45 ? localCycleLength++ : null,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Period Duration (days)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setDialogState(
                      () => localPeriodDuration > 3
                          ? localPeriodDuration--
                          : null,
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$localPeriodDuration',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setDialogState(
                      () => localPeriodDuration < 10
                          ? localPeriodDuration++
                          : null,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                state.updateCycleLength(localCycleLength);
                state.updatePeriodDuration(localPeriodDuration);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final nextPeriodDate = userState.getNextPeriodDate();
    final daysUntil = userState.getDaysUntilNextPeriod();
    final isOnPeriod = userState.isOnPeriod();
    final currentDay = userState.getCurrentPeriodDay();
    final phase = userState.getCyclePhase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, userState),
          ),
        ],
      ),
      body: userState.lastPeriodDate == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No cycle data yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showInitialSetupDialog(context, userState),
                    icon: const Icon(Icons.add),
                    label: const Text('Set Up Tracker'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Main Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOnPeriod
                            ? [const Color(0xFFE91E63), const Color(0xFFC2185B)]
                            : [
                                const Color(0xFF9C27B0),
                                const Color(0xFF7B1FA2),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: (isOnPeriod ? Colors.pink : Colors.purple)
                              .withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isOnPeriod ? Icons.water_drop : Icons.event,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isOnPeriod ? 'Period in Progress' : 'Next Period',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isOnPeriod) ...[
                          Text(
                            'Day $currentDay',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of ${userState.periodDuration}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ] else if (nextPeriodDate != null) ...[
                          Text(
                            DateFormat('MMM d').format(nextPeriodDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              daysUntil == 0
                                  ? 'Today'
                                  : daysUntil == 1
                                  ? 'Tomorrow'
                                  : 'in $daysUntil days',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current Phase Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    decoration: BoxDecoration(
                      color: _phaseColor(phase).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _phaseColor(phase).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_phaseEmoji(phase), style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text(
                          'Current Phase: ${_phaseName(phase)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _phaseColor(phase),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(Day ${userState.getDayInCycle()})',
                          style: TextStyle(
                            color: _phaseColor(phase).withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => userState.logPeriodStart(),
                          icon: const Icon(Icons.fiber_manual_record),
                          label: const Text('Log Period'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _selectLastPeriodDate(context, userState),
                          icon: const Icon(Icons.edit_calendar),
                          label: const Text('Edit Date'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.pink,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: const BorderSide(
                              color: Colors.pink,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Cards
                  _buildInfoCard(
                    'Last Period',
                    DateFormat('MMM d, yyyy').format(userState.lastPeriodDate!),
                    Icons.event,
                    Colors.purple,
                  ),
                  _buildInfoCard(
                    'Cycle Length',
                    '${userState.cycleLength} days',
                    Icons.loop,
                    Colors.blue,
                  ),
                  _buildInfoCard(
                    'Period Duration',
                    '${userState.periodDuration} days',
                    Icons.timelapse,
                    Colors.teal,
                  ),
                ],
              ),
            ),
    );
  }

  Color _phaseColor(String phase) {
    switch (phase) {
      case 'menstrual': return Colors.pink;
      case 'follicular': return Colors.green;
      case 'ovulatory': return Colors.orange;
      case 'luteal': return Colors.purple;
      default: return Colors.blue;
    }
  }

  String _phaseEmoji(String phase) {
    switch (phase) {
      case 'menstrual': return '🌸';
      case 'follicular': return '🌱';
      case 'ovulatory': return '⚡';
      case 'luteal': return '🧘';
      default: return '💪';
    }
  }

  String _phaseName(String phase) {
    switch (phase) {
      case 'menstrual': return 'Menstrual';
      case 'follicular': return 'Follicular';
      case 'ovulatory': return 'Ovulatory';
      case 'luteal': return 'Luteal';
      default: return 'General';
    }
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
