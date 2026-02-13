import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/herself_core.dart';

class DailyPlannerScreen extends StatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  State<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends State<DailyPlannerScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Planner')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _textController.clear();
          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) => AlertDialog(
                title: const Text('Add Task'),
                content: TextField(
                  controller: _textController,
                  autofocus: true,
                  onChanged: (val) => setDialogState(() {}),
                  decoration: const InputDecoration(hintText: 'What needs to be done?'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _textController.text.trim().isEmpty
                        ? null
                        : () {
                            Provider.of<UserState>(context, listen: false).addTask(_textController.text);
                            Navigator.pop(context);
                          },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: userState.tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('All caught up! Add a task to start.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              itemCount: userState.tasks.length,
              itemBuilder: (context, index) {
                final task = userState.tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.circle_outlined, color: Colors.blue),
                    title: Text(task.title),
                    trailing: IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => Provider.of<UserState>(context, listen: false).removeTask(task.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
