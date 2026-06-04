class Course {
  final String id;
  final String name;

  Course({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      name: map['name'],
    );
  }
}

enum SessionStatus { draft, saved, synced }

class AttendanceSession {
  final String sessionId;
  final String courseId;
  final String courseName;
  final DateTime createdAt;
  final SessionStatus status;
  final bool synced;

  AttendanceSession({
    required this.sessionId,
    required this.courseId,
    required this.courseName,
    required this.createdAt,
    this.status = SessionStatus.draft,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'course_id': courseId,
      'course_name': courseName,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'synced': synced ? 1 : 0,
    };
  }

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    return AttendanceSession(
      sessionId: map['session_id'],
      courseId: map['course_id'],
      courseName: map['course_name'],
      createdAt: DateTime.parse(map['created_at']),
      status: SessionStatus.values.byName(map['status']),
      synced: map['synced'] == 1,
    );
  }
}

class AttendanceRecord {
  final int? id;
  final String sessionId;
  final String studentId;
  final DateTime scannedAt;

  AttendanceRecord({
    this.id,
    required this.sessionId,
    required this.studentId,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'student_id': studentId,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      sessionId: map['session_id'],
      studentId: map['student_id'],
      scannedAt: DateTime.parse(map['scanned_at']),
    );
  }
}
