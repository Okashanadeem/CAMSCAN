import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../providers/providers.dart';
import 'scan_screen.dart';

class SessionScreen extends ConsumerWidget {
  final AttendanceSession session;

  const SessionScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceList = ref.watch(activeSessionAttendanceProvider(session.sessionId));
    final isEditable = session.status == SessionStatus.draft;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.courseName),
        actions: [
          if (isEditable)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _confirmSave(context, ref),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSessionHeader(context),
          const Divider(height: 1),
          Expanded(
            child: attendanceList.isEmpty
                ? const Center(child: Text('No students scanned yet.'))
                : ListView.builder(
                    itemCount: attendanceList.length,
                    itemBuilder: (context, index) {
                      final record = attendanceList[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text((index + 1).toString())),
                        title: Text(record.studentId, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('HH:mm:ss').format(record.scannedAt)),
                        trailing: isEditable
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => ref
                                    .read(activeSessionAttendanceProvider(session.sessionId).notifier)
                                    .removeStudent(record.id!),
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isEditable
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanScreen(sessionId: session.sessionId),
                  ),
                );
              },
              label: const Text('Scan Student'),
              icon: const Icon(Icons.qr_code_scanner),
            )
          : null,
    );
  }

  Widget _buildSessionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Course ID: ${session.courseId}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(session.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(session.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  session.status.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.draft:
        return Colors.orange;
      case SessionStatus.saved:
        return Colors.blue;
      case SessionStatus.synced:
        return Colors.green;
    }
  }

  void _confirmSave(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Session'),
        content: const Text('Once saved, the session will be read-only. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(sessionsProvider.notifier).saveSession(session.sessionId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to Home/Previous
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
