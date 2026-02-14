import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/herself_core.dart';
import 'dart:async';

class WorkoutExercise {
  final String name;
  final String description;
  final String setsReps;
  final int durationSeconds;
  final IconData icon;
  final String difficulty;

  const WorkoutExercise({
    required this.name,
    required this.description,
    required this.setsReps,
    required this.durationSeconds,
    required this.icon,
    required this.difficulty,
  });
}

class PhaseWorkout {
  final String phaseName;
  final String phaseEmoji;
  final String description;
  final String intensity;
  final Color color;
  final Color darkColor;
  final List<WorkoutExercise> exercises;
  final List<String> tips;

  const PhaseWorkout({
    required this.phaseName,
    required this.phaseEmoji,
    required this.description,
    required this.intensity,
    required this.color,
    required this.darkColor,
    required this.exercises,
    required this.tips,
  });
}

// --- Workout Data for Each Cycle Phase ---

final Map<String, PhaseWorkout> phaseWorkouts = {
  'menstrual': PhaseWorkout(
    phaseName: 'Menstrual Phase',
    phaseEmoji: '🌸',
    description: 'Your body needs rest & recovery. Focus on gentle movements to ease cramps and improve circulation.',
    intensity: 'Low',
    color: const Color(0xFFF8BBD0),
    darkColor: const Color(0xFFE91E63),
    exercises: const [
      WorkoutExercise(
        name: 'Gentle Yoga Flow',
        description: 'Sun salutations at a slow, mindful pace. Focus on hip openers.',
        setsReps: '10 min flow',
        durationSeconds: 600,
        icon: Icons.self_improvement,
        difficulty: 'Easy',
      ),
      WorkoutExercise(
        name: 'Cat-Cow Stretches',
        description: 'Relieves lower back pain and gently massages organs.',
        setsReps: '3 sets × 10 reps',
        durationSeconds: 180,
        icon: Icons.accessibility_new,
        difficulty: 'Easy',
      ),
      WorkoutExercise(
        name: 'Seated Forward Fold',
        description: 'Calms the nervous system, stretches hamstrings and lower back.',
        setsReps: 'Hold 60 sec × 3',
        durationSeconds: 180,
        icon: Icons.airline_seat_recline_normal,
        difficulty: 'Easy',
      ),
      WorkoutExercise(
        name: 'Light Walk',
        description: 'Gentle walking to boost circulation without straining.',
        setsReps: '15 minutes',
        durationSeconds: 900,
        icon: Icons.directions_walk,
        difficulty: 'Easy',
      ),
      WorkoutExercise(
        name: 'Deep Breathing',
        description: 'Box breathing: inhale 4s, hold 4s, exhale 4s, hold 4s.',
        setsReps: '5 min session',
        durationSeconds: 300,
        icon: Icons.air,
        difficulty: 'Easy',
      ),
      WorkoutExercise(
        name: 'Supine Twist',
        description: 'Lying spinal twist to release tension in the lower back.',
        setsReps: 'Hold 45 sec each side',
        durationSeconds: 90,
        icon: Icons.rotate_right,
        difficulty: 'Easy',
      ),
    ],
    tips: [
      'Listen to your body — skip any exercise that causes discomfort',
      'Stay warm and hydrated',
      'Iron-rich foods help replenish what you lose during your period',
    ],
  ),
  'follicular': PhaseWorkout(
    phaseName: 'Follicular Phase',
    phaseEmoji: '🌱',
    description: 'Energy is rising! Your body recovers faster and builds strength efficiently. Push your limits!',
    intensity: 'High',
    color: const Color(0xFFC8E6C9),
    darkColor: const Color(0xFF388E3C),
    exercises: const [
      WorkoutExercise(
        name: 'HIIT Circuit',
        description: '30s work / 15s rest. Jumping jacks, burpees, mountain climbers, high knees.',
        setsReps: '4 rounds × 4 exercises',
        durationSeconds: 720,
        icon: Icons.flash_on,
        difficulty: 'Hard',
      ),
      WorkoutExercise(
        name: 'Squats',
        description: 'Bodyweight or weighted squats. Keep back straight, go below parallel.',
        setsReps: '4 sets × 12 reps',
        durationSeconds: 300,
        icon: Icons.fitness_center,
        difficulty: 'Medium',
      ),
      WorkoutExercise(
        name: 'Push-Ups',
        description: 'Full or modified push-ups. Engage core throughout.',
        setsReps: '3 sets × 15 reps',
        durationSeconds: 240,
        icon: Icons.sports_gymnastics,
        difficulty: 'Medium',
      ),
      WorkoutExercise(
        name: 'Lunges',
        description: 'Forward and reverse lunges. Keep front knee behind toes.',
        setsReps: '3 sets × 12 each leg',
        durationSeconds: 360,
        icon: Icons.directions_walk,
        difficulty: 'Medium',
      ),
      WorkoutExercise(
        name: 'Plank Hold',
        description: 'Forearm plank. Keep body in straight line, engage core.',
        setsReps: '3 sets × 45 sec',
        durationSeconds: 135,
        icon: Icons.straighten,
        difficulty: 'Medium',
      ),
      WorkoutExercise(
        name: 'Cardio Run',
        description: 'Moderate-pace run or brisk walk. Great time for endurance building.',
        setsReps: '20 minutes',
        durationSeconds: 1200,
        icon: Icons.directions_run,
        difficulty: 'Hard',
      ),
    ],
    tips: [
      'Estrogen is rising — muscle repair is faster, so push hard!',
      'Try new exercises or increase weights this phase',
      'Fuel with complex carbs and protein for energy',
    ],
  ),
  'ovulatory': PhaseWorkout(
    phaseName: 'Ovulatory Phase',
    phaseEmoji: '⚡',
    description: 'Peak energy & strength! You\'re at your most powerful. Maximize performance!',
    intensity: 'Peak',
    color: const Color(0xFFFFF9C4),
    darkColor: const Color(0xFFF57F17),
    exercises: const [
      WorkoutExercise(
        name: 'Sprint Intervals',
        description: 'All-out sprint 20s, walk 40s. Maximum effort sprints!',
        setsReps: '8 rounds',
        durationSeconds: 480,
        icon: Icons.speed,
        difficulty: 'Intense',
      ),
      WorkoutExercise(
        name: 'Deadlifts',
        description: 'Bodyweight or weighted. Hinge at hips, flat back, squeeze glutes.',
        setsReps: '4 sets × 10 reps',
        durationSeconds: 300,
        icon: Icons.fitness_center,
        difficulty: 'Hard',
      ),
      WorkoutExercise(
        name: 'Box Jumps / Jump Squats',
        description: 'Explosive plyometric movements. Land softly, reset between reps.',
        setsReps: '4 sets × 8 reps',
        durationSeconds: 240,
        icon: Icons.upload,
        difficulty: 'Hard',
      ),
      WorkoutExercise(
        name: 'Shoulder Press',
        description: 'Overhead press with weights or resistance bands.',
        setsReps: '3 sets × 12 reps',
        durationSeconds: 240,
        icon: Icons.fitness_center,
        difficulty: 'Medium',
      ),
      WorkoutExercise(
        name: 'Burpees',
        description: 'Full burpees with push-up and jump. Total body power move.',
        setsReps: '3 sets × 10 reps',
        durationSeconds: 300,
        icon: Icons.sports_gymnastics,
        difficulty: 'Intense',
      ),
      WorkoutExercise(
        name: 'Core Blast',
        description: 'Circuit: bicycle crunches, leg raises, Russian twists, plank.',
        setsReps: '3 rounds × 30 sec each',
        durationSeconds: 360,
        icon: Icons.radio_button_checked,
        difficulty: 'Hard',
      ),
    ],
    tips: [
      'You\'re at peak testosterone — best time for personal records!',
      'Group workouts are great for this social, high-energy phase',
      'Hydrate extra as you\'ll sweat more during intense sessions',
    ],
  ),
  'luteal': PhaseWorkout(
    phaseName: 'Luteal Phase',
    phaseEmoji: '🧘',
    description: 'Energy gradually decreases. Focus on moderate activity, flexibility, and stress relief.',
    intensity: 'Medium',
    color: const Color(0xFFD1C4E9),
    darkColor: const Color(0xFF7B1FA2),
    exercises: const [
      WorkoutExercise(
        name: 'Pilates Core Work',
        description: 'Controlled movements focusing on deep core muscles and stability.',
        setsReps: '15 min session',
        durationSeconds: 900,
        icon: Icons.self_improvement,
        difficulty: 'Medium',
      ),
      WorkoutExercise(
        name: 'Swimming / Low-Impact Cardio',
        description: 'Swimming, cycling, or elliptical at moderate pace.',
        setsReps: '20 minutes',
        durationSeconds: 1200,
        icon: Icons.pool,
        difficulty: 'Medium',
      ),
      WorkoutExercise(
        name: 'Resistance Band Work',
        description: 'Upper body: rows, bicep curls, chest presses with bands.',
        setsReps: '3 sets × 12 reps each',
        durationSeconds: 360,
        icon: Icons.fitness_center,
        difficulty: 'Medium',
      ),
      WorkoutExercise(
        name: 'Glute Bridges',
        description: 'Slow, controlled bridges. Hold at top for 3 seconds.',
        setsReps: '3 sets × 15 reps',
        durationSeconds: 270,
        icon: Icons.accessibility_new,
        difficulty: 'Easy',
      ),
      WorkoutExercise(
        name: 'Flexibility Flow',
        description: 'Full body stretching routine. Hold each stretch 30+ seconds.',
        setsReps: '10 min session',
        durationSeconds: 600,
        icon: Icons.self_improvement,
        difficulty: 'Easy',
      ),
      WorkoutExercise(
        name: 'Meditation & Body Scan',
        description: 'Guided body scan meditation to manage PMS symptoms.',
        setsReps: '10 minutes',
        durationSeconds: 600,
        icon: Icons.spa,
        difficulty: 'Easy',
      ),
    ],
    tips: [
      'Progesterone is high — you may feel warmer and tire faster',
      'Magnesium-rich foods can help with bloating and mood',
      'Don\'t pressure yourself — moderate exercise is perfect now',
    ],
  ),
};

final PhaseWorkout unknownPhaseWorkout = PhaseWorkout(
  phaseName: 'General Fitness',
  phaseEmoji: '💪',
  description: 'Set up your cycle tracker to get personalized workout plans! Here\'s a balanced routine.',
  intensity: 'Medium',
  color: const Color(0xFFB3E5FC),
  darkColor: const Color(0xFF0288D1),
  exercises: const [
    WorkoutExercise(
      name: 'Warm-Up Jog',
      description: 'Light jogging in place or around the room.',
      setsReps: '5 minutes',
      durationSeconds: 300,
      icon: Icons.directions_run,
      difficulty: 'Easy',
    ),
    WorkoutExercise(
      name: 'Bodyweight Squats',
      description: 'Stand shoulder-width apart, squat down and back up.',
      setsReps: '3 sets × 15 reps',
      durationSeconds: 240,
      icon: Icons.fitness_center,
      difficulty: 'Medium',
    ),
    WorkoutExercise(
      name: 'Push-Ups',
      description: 'Standard or knee push-ups. Keep core tight.',
      setsReps: '3 sets × 10 reps',
      durationSeconds: 180,
      icon: Icons.sports_gymnastics,
      difficulty: 'Medium',
    ),
    WorkoutExercise(
      name: 'Plank Hold',
      description: 'Hold a forearm plank position.',
      setsReps: '3 sets × 30 sec',
      durationSeconds: 90,
      icon: Icons.straighten,
      difficulty: 'Medium',
    ),
    WorkoutExercise(
      name: 'Cool-Down Stretch',
      description: 'Full body stretch focusing on major muscle groups.',
      setsReps: '5 minutes',
      durationSeconds: 300,
      icon: Icons.self_improvement,
      difficulty: 'Easy',
    ),
  ],
  tips: [
    'Set up the cycle tracker for workouts tailored to your body!',
    'Stay consistent — even 15 minutes a day makes a difference',
    'Warm up before and cool down after every session',
  ],
);

// --- Workout Screen Widget ---

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int? _activeTimerIndex;
  int _timerSeconds = 0;
  Timer? _timer;
  final Set<int> _completedExercises = {};

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int index, int durationSeconds) {
    _timer?.cancel();
    setState(() {
      _activeTimerIndex = index;
      _timerSeconds = durationSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
        setState(() {
          _completedExercises.add(index);
          _activeTimerIndex = null;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _activeTimerIndex = null);
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy': return Colors.green;
      case 'Medium': return Colors.orange;
      case 'Hard': return Colors.red;
      case 'Intense': return Colors.deepPurple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final phase = userState.getCyclePhase();
    final dayInCycle = userState.getDayInCycle();
    final workout = phaseWorkouts[phase] ?? unknownPhaseWorkout;
    final totalExercises = workout.exercises.length;
    final completedCount = _completedExercises.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Workout Plan'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [workout.color, workout.darkColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: workout.darkColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(workout.phaseEmoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Text(
                            workout.phaseName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          workout.intensity,
                          style: TextStyle(
                            color: workout.darkColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (phase != 'unknown') ...[
                    const SizedBox(height: 8),
                    Text(
                      'Day $dayInCycle of Cycle',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    workout.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress
            if (completedCount > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: completedCount / totalExercises,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(workout.darkColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$completedCount / $totalExercises',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: workout.darkColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Today's Exercises
            const Text(
              "Today's Exercises",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...List.generate(workout.exercises.length, (index) {
              final exercise = workout.exercises[index];
              final isActive = _activeTimerIndex == index;
              final isCompleted = _completedExercises.contains(index);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : isActive
                          ? workout.color.withOpacity(0.3)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? workout.darkColor
                        : isCompleted
                            ? Colors.green.shade300
                            : Colors.grey.shade200,
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.green.shade100
                                  : workout.color.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : exercise.icon,
                              color: isCompleted ? Colors.green : workout.darkColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    color: isCompleted ? Colors.grey : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exercise.setsReps,
                                  style: TextStyle(
                                    color: workout.darkColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise.difficulty,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getDifficultyColor(exercise.difficulty),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        exercise.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Timer / Action Row
                      if (isActive) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: workout.darkColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer, color: workout.darkColor),
                              const SizedBox(width: 12),
                              Text(
                                _formatTime(_timerSeconds),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: workout.darkColor,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: _stopTimer,
                                icon: const Icon(Icons.stop_circle, size: 32),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ] else if (!isCompleted) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _startTimer(index, exercise.durationSeconds),
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('Start Timer'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: workout.darkColor,
                                  side: BorderSide(color: workout.darkColor.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => setState(() => _completedExercises.add(index)),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Done'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: BorderSide(color: Colors.green.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Tips Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: workout.color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: workout.darkColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: workout.darkColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for This Phase',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: workout.darkColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...workout.tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: workout.darkColor, fontSize: 16)),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
