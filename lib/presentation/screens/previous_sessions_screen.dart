import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import 'session_screen.dart';

class PreviousSessionsScreen extends ConsumerWidget {
  const PreviousSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Sessions'),
      ),
      body: sessions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No sessions recorded yet.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(session.courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(session.createdAt)}'),
                        const SizedBox(height: 4),
                        _buildSyncBadge(session.synced),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SessionScreen(session: session),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSyncBadge(bool synced) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: synced ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: synced ? Colors.green : Colors.orange),
      ),
      child: Text(
        synced ? 'SYNCED' : 'PENDING SYNC',
        style: TextStyle(
          color: synced ? Colors.green : Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
