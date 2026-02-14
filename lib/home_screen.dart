import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/boost_screen.dart';
import 'screens/safe_space_screen.dart';
import 'screens/daily_planner_screen.dart';
import 'screens/health_care_screen.dart';
import 'screens/guardian_screen.dart';
import 'screens/workout_screen.dart';
import 'core/herself_core.dart';
import 'core/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/db_viewer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showEditProfile(BuildContext context, UserState state) {
    final controller = TextEditingController(text: state.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Your Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              state.updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userState = Provider.of<UserState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                _showEditProfile(context, userState);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(authService.currentUserEmail ?? 'Not set'),
            ),
            if (!kIsWeb) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.storage_rounded, color: Colors.indigo),
                title: const Text('View SQLite Database'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DbViewerScreen()));
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                authService.logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final suggested = userState.getSuggestedModule();
    final theme = Theme.of(context);

    final Map<String, Widget> screenMap = {
      'Boost': const BoostScreen(),
      'HerTalk': const SafeSpaceScreen(),
      'Daily Planner': const DailyPlannerScreen(),
      'Health Care': const HealthCareScreen(),
      'Guardian': const GuardianScreen(),
      'Workout': const WorkoutScreen(),
    };

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Elegant Mesh Background Refined
          Positioned(
            top: -150,
            right: -100,
            child: _buildDecorativeCircle(400, theme.colorScheme.primary.withOpacity(0.15)),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: _buildDecorativeCircle(300, theme.colorScheme.secondary.withOpacity(0.1)),
          ),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                userState.name,
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _showProfileMenu(context),
                            child: Hero(
                              tag: 'profile',
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Abstract Radiant Illustration Card
                      GestureDetector(
                        onTap: () {
                          if (screenMap.containsKey(suggested)) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => screenMap[suggested]!),
                            );
                          }
                        },
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Stack(
                              children: [
                                CustomPaint(
                                  painter: RadiantBackgroundPainter(),
                                  size: Size.infinite,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Daily Suggestion',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white.withOpacity(0.8),
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      Text(
                                        'Try ${suggested} today',
                                        style: GoogleFonts.outfit(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 20,
                                  bottom: 20,
                                  child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.5), size: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Daily Mood Check',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('EEEE, MMM d').format(DateTime.now()),
                            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMoodSelector(context, userState),

                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.bolt_rounded, color: Colors.orange, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Energy Level', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                  ],
                                ),
                                Text(
                                  '${userState.energyLevel}/10',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 5),
                                activeTrackColor: theme.colorScheme.primary,
                                inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.1),
                                thumbColor: Colors.white,
                                overlayColor: theme.colorScheme.primary.withOpacity(0.1),
                              ),
                              child: Slider(
                                value: userState.energyLevel.toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 9,
                                onChanged: (val) => userState.updateEnergy(val.toInt()),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),
                      Text(
                        'Your Toolkit',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.05,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildModuleCard(context, 'Boost', Icons.auto_graph_rounded, Colors.orange, const BoostScreen()),
                    _buildModuleCard(context, 'HerTalk', Icons.chat_bubble_rounded, Colors.teal, const SafeSpaceScreen()),
                    _buildModuleCard(context, 'Planner', Icons.calendar_today_rounded, Colors.blue, const DailyPlannerScreen()),
                    _buildModuleCard(context, 'Health', Icons.favorite_rounded, Colors.redAccent, const HealthCareScreen()),
                    _buildModuleCard(context, 'Guardian', Icons.shield_rounded, Colors.indigo, const GuardianScreen()),
                    _buildModuleCard(context, 'Workout', Icons.directions_run_rounded, Colors.deepOrange, const WorkoutScreen()),
                  ]),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context, UserState state) {
    final theme = Theme.of(context);
    final moods = {
      'happy': '😊',
      'stressed': '😫',
      'tired': '😴',
      'calm': '😌',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.entries.map((entry) {
        bool isSelected = state.mood == entry.key;
        return GestureDetector(
          onTap: () => state.updateMood(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isSelected 
                  ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]
                  : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Text(entry.value, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  entry.key[0].toUpperCase() + entry.key.substring(1),
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Provider.of<UserState>(context, listen: false).logInteraction(title);
            Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.7), color],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RadiantBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Drawing abstract geometric shapes with low opacity
    final path = Path();
    
    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), size.width * 0.4, paint);
    
    paint.color = Colors.white.withOpacity(0.03);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), size.width * 0.3, paint);

    final rectPath = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.5)
      ..close();
    
    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawPath(rectPath, paint);

    // Draw wavy lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.2 + i * 0.15);
      final wavePath = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 20) {
        wavePath.lineTo(x, y + (i % 2 == 0 ? 5 : -5));
      }
      canvas.drawPath(wavePath, linePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
