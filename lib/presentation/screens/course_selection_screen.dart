import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'session_screen.dart';

class CourseSelectionScreen extends ConsumerWidget {
  const CourseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Course'),
      ),
      body: courses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No courses found.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.read(coursesProvider.notifier).syncCourses(),
                    child: const Text('Fetch Courses'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: ${course.id}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final session = await ref.read(sessionsProvider.notifier).createSession(course);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SessionScreen(session: session),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
