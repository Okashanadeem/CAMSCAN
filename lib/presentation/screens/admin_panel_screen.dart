import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminTile(
            context,
            icon: Icons.download,
            title: 'Pull Latest Courses',
            subtitle: 'Fetch courses from API and update local cache',
            onTap: () => _handleFetchCourses(context, ref),
          ),
          const SizedBox(height: 16),
          _buildAdminTile(
            context,
            icon: Icons.upload,
            title: 'Push Sessions to Server',
            subtitle: 'Upload all unsynced sessions to the server',
            onTap: () => _handleSyncSessions(context, ref),
          ),
          const Divider(height: 48),
          const Text(
            'Data Management',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildAdminTile(
            context,
            icon: Icons.delete_outline,
            title: 'Clear Sessions Only',
            subtitle: 'Delete all local sessions and attendance data',
            color: Colors.red.shade700,
            onTap: () => _showClearDialog(context, ref, clearAll: false),
          ),
          const SizedBox(height: 16),
          _buildAdminTile(
            context,
            icon: Icons.delete_forever,
            title: 'Clear Everything',
            subtitle: 'Delete sessions, attendance, and course cache',
            color: Colors.red.shade900,
            onTap: () => _showClearDialog(context, ref, clearAll: true),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleFetchCourses(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await ref.read(coursesProvider.notifier).syncCourses();

    if (context.mounted) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Courses updated successfully')),
      );
    }
  }

  Future<void> _handleSyncSessions(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await ref.read(sessionsProvider.notifier).syncSessions();

    if (context.mounted) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessions synced successfully')),
      );
    }
  }

  void _showClearDialog(BuildContext context, WidgetRef ref, {required bool clearAll}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(clearAll ? 'Clear Everything?' : 'Clear Sessions?'),
        content: Text(clearAll
            ? 'This will delete ALL sessions, attendance records, and cached courses. This action cannot be undone.'
            : 'This will delete all sessions and attendance records. Courses will be kept. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (clearAll) {
                await ref.read(sessionsProvider.notifier).clearAll();
              } else {
                await ref.read(databaseProvider).clearSessions();
                await ref.read(sessionsProvider.notifier).loadSessions();
              }
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data cleared successfully')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
