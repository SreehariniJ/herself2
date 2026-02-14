import 'package:flutter/material.dart';
import '../core/database_helper.dart';
import 'package:intl/intl.dart';

class DbViewerScreen extends StatefulWidget {
  const DbViewerScreen({super.key});

  @override
  State<DbViewerScreen> createState() => _DbViewerScreenState();
}

class _DbViewerScreenState extends State<DbViewerScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() => _isLoading = true);
    final users = await _dbHelper.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local SQLite Database', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshUsers,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storage_rounded, size: 64, color: theme.colorScheme.primary.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text('No users found in SQLite', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final createdAt = DateTime.tryParse(user['created_at'] ?? '') ?? DateTime.now();
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1)),
                    ),
                    color: Colors.white.withOpacity(0.8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          user['id'].toString(),
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        user['name'] ?? 'No Name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['email'] ?? 'No Email'),
                          const SizedBox(height: 4),
                          Text(
                            'Joined: ${DateFormat('MMM d, yyyy HH:mm').format(createdAt)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
