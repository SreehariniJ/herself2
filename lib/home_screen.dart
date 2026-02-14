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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final suggested = userState.getSuggestedModule();

    final Map<String, Widget> screenMap = {
      'Boost': const BoostScreen(),
      'HerTalk': const SafeSpaceScreen(),
      'Daily Planner': const DailyPlannerScreen(),
      'Health Care': const HealthCareScreen(),
      'Guardian': const GuardianScreen(),
      'Workout': const WorkoutScreen(),
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () => _showProfileMenu(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'HERSELF',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, ${userState.name}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Recommendations Section
                  GestureDetector(
                    onTap: () {
                      if (screenMap.containsKey(suggested)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => screenMap[suggested]!,
                          ),
                        );
                      }
                    },
                    child: _buildRecommendationCard(context, suggested),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    'How are you feeling?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMoodSelector(context, userState),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Energy Level',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${userState.energyLevel}/10',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: userState.energyLevel.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (val) => userState.updateEnergy(val.toInt()),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'Explore Modules',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildModuleCard(
                  context,
                  'Boost',
                  Icons.bolt,
                  Colors.orange,
                  const BoostScreen(),
                ),
                _buildModuleCard(
                  context,
                  'HerTalk',
                  Icons.spa,
                  Colors.teal,
                  const SafeSpaceScreen(),
                ),
                _buildModuleCard(
                  context,
                  'Daily Planner',
                  Icons.event_note,
                  Colors.blue,
                  const DailyPlannerScreen(),
                ),
                _buildModuleCard(
                  context,
                  'Health Care',
                  Icons.favorite,
                  Colors.redAccent,
                  const HealthCareScreen(),
                ),
                _buildModuleCard(
                  context,
                  'Guardian',
                  Icons.security,
                  Colors.indigo,
                  const GuardianScreen(),
                ),
                _buildModuleCard(
                  context,
                  'Workout',
                  Icons.fitness_center,
                  Colors.deepOrange,
                  const WorkoutScreen(),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, String module) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended for you',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Open $module',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context, UserState state) {
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
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[200]!,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(entry.value, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return InkWell(
      onTap: () {
        Provider.of<UserState>(context, listen: false).logInteraction(
          title == 'Daily Planner'
              ? 'Daily Planner'
              : (title == 'Health Care' ? 'Health Care' : title),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
