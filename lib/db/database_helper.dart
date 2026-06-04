import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'attendance_system.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Courses table
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');

    // Sessions table
    await db.execute('''
      CREATE TABLE sessions (
        session_id TEXT PRIMARY KEY,
        course_id TEXT,
        course_name TEXT,
        created_at TEXT,
        status TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT,
        student_id TEXT,
        scanned_at TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions (session_id) ON DELETE CASCADE
      )
    ''');
  }

  // Course methods
  Future<void> insertCourses(List<Course> courses) async {
    final db = await database;
    Batch batch = db.batch();
    for (var course in courses) {
      batch.insert('courses', course.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Course>> getCourses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return List.generate(maps.length, (i) => Course.fromMap(maps[i]));
  }

  // Session methods
  Future<void> insertSession(AttendanceSession session) async {
    final db = await database;
    await db.insert('sessions', session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AttendanceSession>> getSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sessions', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => AttendanceSession.fromMap(maps[i]));
  }

  Future<void> updateSessionStatus(String sessionId, SessionStatus status, {bool synced = false}) async {
    final db = await database;
    await db.update(
      'sessions',
      {'status': status.name, 'synced': synced ? 1 : 0},
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  // Attendance methods
  Future<void> insertAttendance(AttendanceRecord record) async {
    final db = await database;
    await db.insert('attendance', record.toMap());
  }

  Future<List<AttendanceRecord>> getAttendanceForSession(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    return List.generate(maps.length, (i) => AttendanceRecord.fromMap(maps[i]));
  }

  Future<void> deleteAttendanceRecord(int id) async {
    final db = await database;
    await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  // Admin methods
  Future<void> clearSessions() async {
    final db = await database;
    await db.delete('attendance');
    await db.delete('sessions');
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('attendance');
    await db.delete('sessions');
    await db.delete('courses');
  }

  Future<List<AttendanceSession>> getUnsyncedSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'synced = 0 AND status = ?',
      whereArgs: [SessionStatus.saved.name],
    );
    return List.generate(maps.length, (i) => AttendanceSession.fromMap(maps[i]));
  }
}
