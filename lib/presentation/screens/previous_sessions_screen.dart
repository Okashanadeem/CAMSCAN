import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import 'session_screen.dart';

class PreviousSessionsScreen extends ConsumerStatefulWidget {
  const PreviousSessionsScreen({super.key});

  @override
  ConsumerState<PreviousSessionsScreen> createState() => _PreviousSessionsScreenState();
}

class _PreviousSessionsScreenState extends ConsumerState<PreviousSessionsScreen> {
  String searchQuery = '';
  String? selectedCourseId;

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider);
    final courses = ref.watch(coursesProvider);

    final filteredSessions = sessions.where((session) {
      final matchesSearch = session.courseName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          session.courseId.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCourse = selectedCourseId == null || session.courseId == selectedCourseId;
      return matchesSearch && matchesCourse;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Sessions'),
      ),
      body: Column(
        children: [
          _buildFilters(courses),
          Expanded(
            child: filteredSessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSessions.length,
                    itemBuilder: (context, index) {
                      final session = filteredSessions[index];
                      return _buildSessionCard(context, session);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<Course> courses) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search course or ID...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Courses'),
                  selected: selectedCourseId == null,
                  onSelected: (selected) => setState(() => selectedCourseId = null),
                ),
                const SizedBox(width: 8),
                ...courses.map((course) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(course.name),
                        selected: selectedCourseId == course.id,
                        onSelected: (selected) {
                          setState(() => selectedCourseId = selected ? course.id : null);
                        },
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No matching sessions found.'),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, AttendanceSession session) {
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
