import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/herself_core.dart';

class DailyPlannerScreen extends StatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  State<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends State<DailyPlannerScreen> {
  late TextEditingController _textController;
  DateTime? _selectedReminder;

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

  Future<void> _pickDateTime(StateSetter setDialogState) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setDialogState(() {
      _selectedReminder = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Planner'), elevation: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _textController.clear();
          _selectedReminder = null;

          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) => AlertDialog(
                title: const Text('Add Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _textController,
                      autofocus: true,
                      onChanged: (val) => setDialogState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'What needs to be done?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_selectedReminder != null)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.teal.shade100),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.alarm,
                                    size: 16,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat(
                                      'MMM d, h:mm a',
                                    ).format(_selectedReminder!),
                                    style: TextStyle(
                                      color: Colors.teal.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () => setDialogState(
                                      () => _selectedReminder = null,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.teal.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_selectedReminder == null)
                          TextButton.icon(
                            onPressed: () => _pickDateTime(setDialogState),
                            icon: const Icon(Icons.notifications_none),
                            label: const Text("Set Reminder"),
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
                    onPressed: _textController.text.trim().isEmpty
                        ? null
                        : () {
                            Provider.of<UserState>(
                              context,
                              listen: false,
                            ).addTask(
                              _textController.text,
                              reminder: _selectedReminder,
                            );
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          );
        },
        label: const Text("New Task"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      body: userState.tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'All caught up!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add a task to start your day.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 80,
              ),
              itemCount: userState.tasks.length,
              itemBuilder: (context, index) {
                final task = userState.tasks[index];
                final hasReminder = task.reminderTime != null;

                return Dismissible(
                  key: Key(task.id),
                  onDismissed: (_) {
                    Provider.of<UserState>(
                      context,
                      listen: false,
                    ).removeTask(task.id);
                  },
                  background: Container(
                    color: Colors.red.shade100,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: hasReminder
                            ? Colors.teal.shade50
                            : Colors.grey.shade100,
                        child: Icon(
                          hasReminder ? Icons.alarm : Icons.circle_outlined,
                          color: hasReminder ? Colors.teal : Colors.grey,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: hasReminder
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event,
                                    size: 14,
                                    color: Colors.teal.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'MMM d, h:mm a',
                                    ).format(task.reminderTime!),
                                    style: TextStyle(
                                      color: Colors.teal.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.grey,
                        ),
                        onPressed: () => Provider.of<UserState>(
                          context,
                          listen: false,
                        ).removeTask(task.id),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
