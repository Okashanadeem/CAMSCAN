import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../db/database_helper.dart';
import '../../services/api_service.dart';

// Providers
final databaseProvider = Provider((ref) => DatabaseHelper());
final apiServiceProvider = Provider((ref) => ApiService());

final coursesProvider = StateNotifierProvider<CourseNotifier, List<Course>>((ref) {
  return CourseNotifier(ref.watch(databaseProvider), ref.watch(apiServiceProvider));
});

final sessionsProvider = StateNotifierProvider<SessionNotifier, List<AttendanceSession>>((ref) {
  return SessionNotifier(ref.watch(databaseProvider), ref.watch(apiServiceProvider));
});

// Notifiers
class CourseNotifier extends StateNotifier<List<Course>> {
  final DatabaseHelper _db;
  final ApiService _api;

  CourseNotifier(this._db, this._api) : super([]) {
    loadCourses();
  }

  Future<void> loadCourses() async {
    state = await _db.getCourses();
  }

  Future<void> syncCourses() async {
    try {
      final courses = await _api.fetchCourses();
      await _db.insertCourses(courses);
      state = courses;
    } catch (e) {
      // Handle error
    }
  }
}

class SessionNotifier extends StateNotifier<List<AttendanceSession>> {
  final DatabaseHelper _db;
  final ApiService _api;

  SessionNotifier(this._db, this._api) : super([]) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = await _db.getSessions();
  }

  Future<AttendanceSession> createSession(Course course) async {
    final session = AttendanceSession(
      sessionId: const Uuid().v4(),
      courseId: course.id,
      courseName: course.name,
      createdAt: DateTime.now(),
    );
    await _db.insertSession(session);
    await loadSessions();
    return session;
  }

  Future<void> saveSession(String sessionId) async {
    await _db.updateSessionStatus(sessionId, SessionStatus.saved);
    await loadSessions();
  }

  Future<void> syncSessions() async {
    final unsynced = await _db.getUnsyncedSessions();
    if (unsynced.isEmpty) return;

    List<Map<String, dynamic>> payload = [];
    for (var session in unsynced) {
      final attendance = await _db.getAttendanceForSession(session.sessionId);
      payload.add({
        'session_id': session.sessionId,
        'course_id': session.courseId,
        'course_name': session.courseName,
        'created_at': session.createdAt.toIso8601String(),
        'students': attendance.map((a) => {
          'student_id': a.studentId,
          'scanned_at': a.scannedAt.toIso8601String(),
        }).toList(),
      });
    }

    final success = await _api.uploadSessions(payload);
    if (success) {
      for (var session in unsynced) {
        await _db.updateSessionStatus(session.sessionId, SessionStatus.synced, synced: true);
      }
      await loadSessions();
    }
  }

  Future<void> clearAll() async {
    await _db.clearAll();
    await loadSessions();
  }
}

// Active Session Provider
final activeSessionAttendanceProvider = StateNotifierProvider.family<AttendanceListNotifier, List<AttendanceRecord>, String>((ref, sessionId) {
  return AttendanceListNotifier(ref.watch(databaseProvider), sessionId);
});

class AttendanceListNotifier extends StateNotifier<List<AttendanceRecord>> {
  final DatabaseHelper _db;
  final String sessionId;

  AttendanceListNotifier(this._db, this.sessionId) : super([]) {
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    state = await _db.getAttendanceForSession(sessionId);
  }

  bool isDuplicate(String studentId) {
    return state.any((record) => record.studentId == studentId);
  }

  Future<bool> addStudent(String studentId) async {
    if (isDuplicate(studentId)) return false;

    final record = AttendanceRecord(
      sessionId: sessionId,
      studentId: studentId,
      scannedAt: DateTime.now(),
    );
    await _db.insertAttendance(record);
    await loadAttendance();
    return true;
  }

  Future<void> removeStudent(int id) async {
    await _db.deleteAttendanceRecord(id);
    await loadAttendance();
  }
}
