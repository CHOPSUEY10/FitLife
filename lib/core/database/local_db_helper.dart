import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/aktifitas_harian_model.dart';
import '../models/arm_workout_model.dart';
import '../models/chest_workout_model.dart';
import '../models/leg_workout_model.dart';
import '../models/abs_workout_model.dart';
import '../models/cardio_model.dart';
import '../models/target_harian_model.dart';

class LocalDBHelper {
  static final LocalDBHelper instance = LocalDBHelper._init();
  static Database? _database;

  LocalDBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_metrics.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6, // Upgraded from 5 to 6 to support user_id in aktifitas_harian
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Enable FOREIGN KEY enforcement at the SQLite level
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        nama TEXT,
        tanggalLahir TEXT,
        tinggiBadan REAL,
        beratBadan REAL,
        jenisKelamin TEXT,
        tujuan TEXT,
        waktuLuang TEXT,
        isVerified INTEGER
      )
    ''');

    await _createWorkoutTables(db);

    await db.execute('''
      CREATE TABLE aktifitas_harian (
        id_aktifitas_harian INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        id_jenis_aktifitas TEXT,
        total_kalori REAL,
        durasi_latihan INTEGER,
        pace INTEGER,
        jarak_tempuh REAL,
        user_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE target_harian (
        id TEXT PRIMARY KEY,
        targetLangkah INTEGER,
        targetKalori REAL,
        targetDurasiLatihan INTEGER
      )
    ''');

    // Default target seed
    await db.insert('target_harian', {
      'id': 'local_target',
      'targetLangkah': 8000,
      'targetKalori': 500.0,
      'targetDurasiLatihan': 45,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await _seedWorkoutData(db);
  }

  Future<void> _createWorkoutTables(Database db) async {
    const tables = [
      'arm_workout',
      'chest_workout',
      'leg_workout',
      'abs_workout',
      'cardio'
    ];
    
    for (var table in tables) {
      await db.execute('''
        CREATE TABLE $table (
          id_jenis_aktifitas TEXT PRIMARY KEY NOT NULL,
          nama_aktifitas TEXT NOT NULL,
          MET_aktifitas REAL NOT NULL,
          durasi INTEGER,
          reps INTEGER,
          pace INTEGER,
          jarak_tempuh REAL
        )
      ''');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN isVerified INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE jenis_aktifitas (
          id_jenis_aktifitas TEXT PRIMARY KEY NOT NULL,
          nama_aktifitas TEXT NOT NULL,
          MET_aktifitas REAL NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE aktifitas_harian (
          id_aktifitas_harian INTEGER PRIMARY KEY AUTOINCREMENT,
          tanggal TEXT NOT NULL,
          id_jenis_aktifitas TEXT,
          total_kalori REAL,
          durasi_latihan INTEGER,
          pace INTEGER,
          jarak_tempuh REAL,
          FOREIGN KEY (id_jenis_aktifitas) REFERENCES jenis_aktifitas(id_jenis_aktifitas)
        )
      ''');
    }
    if (oldVersion < 4) {
      await _createWorkoutTables(db);
      
      await db.execute('ALTER TABLE aktifitas_harian RENAME TO _aktifitas_harian_old');
      await db.execute('''
        CREATE TABLE aktifitas_harian (
          id_aktifitas_harian INTEGER PRIMARY KEY AUTOINCREMENT,
          tanggal TEXT NOT NULL,
          id_jenis_aktifitas TEXT,
          total_kalori REAL,
          durasi_latihan INTEGER,
          pace INTEGER,
          jarak_tempuh REAL
        )
      ''');
      await db.execute('''
        INSERT INTO aktifitas_harian 
        SELECT id_aktifitas_harian, tanggal, id_jenis_aktifitas, total_kalori, durasi_latihan, pace, jarak_tempuh 
        FROM _aktifitas_harian_old
      ''');
      await db.execute('DROP TABLE _aktifitas_harian_old');
      await db.execute('DROP TABLE IF EXISTS jenis_aktifitas');

      await _seedWorkoutData(db);
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS target_harian (
          id TEXT PRIMARY KEY,
          targetLangkah INTEGER,
          targetKalori REAL,
          targetDurasiLatihan INTEGER
        )
      ''');
      await db.insert('target_harian', {
        'id': 'local_target',
        'targetLangkah': 8000,
        'targetKalori': 500.0,
        'targetDurasiLatihan': 45,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    if (oldVersion < 6) {
      // Upgrade step to add user_id column
      try {
        await db.execute("ALTER TABLE aktifitas_harian ADD COLUMN user_id TEXT DEFAULT 'local_user'");
      } catch (e) {
        // Silently catch in case column already exists
      }
    }
  }

  /// Seed the 5 workout tables with static data
  Future<void> _seedWorkoutData(Database db) async {
    final armWorkouts = [
      ArmWorkoutModel(idJenisAktifitas: 'arm_01', namaAktifitas: 'Bicep Curl', metAktifitas: 3.5, durasi: 35, reps: 12),
      ArmWorkoutModel(idJenisAktifitas: 'arm_02', namaAktifitas: 'Tricep Dip', metAktifitas: 3.5, durasi: 40, reps: 10),
      ArmWorkoutModel(idJenisAktifitas: 'arm_03', namaAktifitas: 'Hammer Curl', metAktifitas: 3.5, durasi: 35, reps: 12),
      ArmWorkoutModel(idJenisAktifitas: 'arm_04', namaAktifitas: 'Overhead Tricep Ext.', metAktifitas: 3.5, durasi: 40, reps: 10),
      ArmWorkoutModel(idJenisAktifitas: 'arm_05', namaAktifitas: 'Chin Up', metAktifitas: 3.5, durasi: 45, reps: 8),
    ];
    for (var w in armWorkouts) {
      await db.insert('arm_workout', w.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    final chestWorkouts = [
      ChestWorkoutModel(idJenisAktifitas: 'chest_01', namaAktifitas: 'Beginner Push Up', metAktifitas: 3.8, durasi: 35, reps: 10),
      ChestWorkoutModel(idJenisAktifitas: 'chest_02', namaAktifitas: 'Diamond Push Up', metAktifitas: 3.8, durasi: 35, reps: 8),
      ChestWorkoutModel(idJenisAktifitas: 'chest_03', namaAktifitas: 'Wide Push Up', metAktifitas: 3.8, durasi: 35, reps: 10),
      ChestWorkoutModel(idJenisAktifitas: 'chest_04', namaAktifitas: 'Incline Push Up', metAktifitas: 3.8, durasi: 40, reps: 12),
      ChestWorkoutModel(idJenisAktifitas: 'chest_05', namaAktifitas: 'Chest Dip', metAktifitas: 3.8, durasi: 45, reps: 10),
    ];
    for (var w in chestWorkouts) {
      await db.insert('chest_workout', w.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    final legWorkouts = [
      LegWorkoutModel(idJenisAktifitas: 'leg_01', namaAktifitas: 'Squat', metAktifitas: 5.0, durasi: 40, reps: 15),
      LegWorkoutModel(idJenisAktifitas: 'leg_02', namaAktifitas: 'Lunge', metAktifitas: 5.0, durasi: 45, reps: 12),
      LegWorkoutModel(idJenisAktifitas: 'leg_03', namaAktifitas: 'Calf Raise', metAktifitas: 5.0, durasi: 30, reps: 20),
      LegWorkoutModel(idJenisAktifitas: 'leg_04', namaAktifitas: 'Wall Sit', metAktifitas: 5.0, durasi: 35, reps: null),
      LegWorkoutModel(idJenisAktifitas: 'leg_05', namaAktifitas: 'Glute Bridge', metAktifitas: 5.0, durasi: 35, reps: 15),
    ];
    for (var w in legWorkouts) {
      await db.insert('leg_workout', w.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    final absWorkouts = [
      AbsWorkoutModel(idJenisAktifitas: 'abs_01', namaAktifitas: 'Plank Crunch', metAktifitas: 4.0, durasi: 30, reps: 10),
      AbsWorkoutModel(idJenisAktifitas: 'abs_02', namaAktifitas: 'Sit Up', metAktifitas: 4.0, durasi: 40, reps: 15),
      AbsWorkoutModel(idJenisAktifitas: 'abs_03', namaAktifitas: 'Leg Raise', metAktifitas: 4.0, durasi: 35, reps: 12),
      AbsWorkoutModel(idJenisAktifitas: 'abs_04', namaAktifitas: 'Russian Twist', metAktifitas: 4.0, durasi: 40, reps: 20),
      AbsWorkoutModel(idJenisAktifitas: 'abs_05', namaAktifitas: 'Bicycle Crunch', metAktifitas: 4.0, durasi: 45, reps: 16),
    ];
    for (var w in absWorkouts) {
      await db.insert('abs_workout', w.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    final cardio = [
      CardioModel(idJenisAktifitas: 'cardio_01', namaAktifitas: 'Jogging / Lari', metAktifitas: 7.0),
    ];
    for (var w in cardio) {
      await db.insert('cardio', w.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // ─── User identification helper ──────────────────────────────

  String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? 'local_user';
  }

  String _getCurrentTargetId() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null ? 'target_$uid' : 'local_target';
  }

  // ─── Users CRUD ─────────────────────────────────────────────

  Future<void> saveUserMetrics(UserModel user) async {
    final db = await instance.database;
    final userMap = user.toMap();
    userMap['id'] = _getCurrentUserId(); 
    
    await db.insert(
      'users',
      userMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUserMetrics() async {
    final db = await instance.database;
    final uid = _getCurrentUserId();
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      // No local record in SQLite. If a Firebase user is logged in, create a default record so they don't have to do onboarding
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final defaultUser = UserModel(
          id: uid,
          nama: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
          tanggalLahir: '2000-01-01',
          tinggiBadan: 170,
          beratBadan: 60,
          jenisKelamin: 'Pria',
          tujuan: 'Turun Berat Badan',
          waktuLuang: '30 - 45 menit',
          isVerified: true,
        );
        // Save it to SQLite so it exists next time
        await saveUserMetrics(defaultUser);
        return defaultUser;
      }
      return null;
    }
  }

  // ─── Target Harian CRUD ─────────────────────────────────────

  Future<void> saveTargetHarian(TargetHarianModel target) async {
    final db = await instance.database;
    final map = target.toMap();
    map['id'] = _getCurrentTargetId();
    await db.insert(
      'target_harian',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TargetHarianModel> getTargetHarian() async {
    final db = await instance.database;
    final targetId = _getCurrentTargetId();
    final maps = await db.query(
      'target_harian',
      where: 'id = ?',
      whereArgs: [targetId],
    );

    if (maps.isNotEmpty) {
      return TargetHarianModel.fromMap(maps.first);
    } else {
      return TargetHarianModel(
        id: targetId,
        targetLangkah: 8000,
        targetKalori: 500.0,
        targetDurasiLatihan: 45,
      );
    }
  }

  // ─── Aktifitas Harian CRUD ──────────────────────────────────

  Future<List<String>> getWorkoutCategories() async {
    return ['Arm Workout', 'Chest Workout', 'Leg Workout', 'Abs Workout', 'Cardio'];
  }

  Future<List<DateTime>> getAktifitasDatesForMonth(int year, int month) async {
    final db = await instance.database;
    final monthStr = month.toString().padLeft(2, '0');
    final queryStr = '$year-$monthStr%';
    
    final results = await db.rawQuery(
      'SELECT DISTINCT tanggal FROM aktifitas_harian WHERE tanggal LIKE ? AND user_id = ?',
      [queryStr, _getCurrentUserId()]
    );

    return results.map((r) => DateTime.parse(r['tanggal'] as String)).toList();
  }

  Future<List<String>> getAllWorkoutNames() async {
    final db = await instance.database;
    final tables = ['arm_workout', 'chest_workout', 'leg_workout', 'abs_workout', 'cardio'];
    final List<String> names = [];
    
    for (var table in tables) {
      final results = await db.query(table, columns: ['nama_aktifitas']);
      for (var row in results) {
        if (row['nama_aktifitas'] != null) {
          names.add(row['nama_aktifitas'] as String);
        }
      }
    }
    return names;
  }

  Future<Map<String, dynamic>?> getWorkoutActivityById(String id) async {
    final db = await instance.database;
    final tables = ['arm_workout', 'chest_workout', 'leg_workout', 'abs_workout', 'cardio'];
    
    for (var table in tables) {
      final results = await db.query(table, where: 'id_jenis_aktifitas = ?', whereArgs: [id]);
      if (results.isNotEmpty) return results.first;
    }
    return null;
  }

  Future<int> insertAktifitasHarian(AktifitasHarianModel model) async {
    final db = await instance.database;
    final map = model.toMap();
    map['user_id'] = _getCurrentUserId();
    return await db.insert('aktifitas_harian', map);
  }

  Future<int> updateAktifitasHarian(AktifitasHarianModel model) async {
    final db = await instance.database;
    final map = model.toMap();
    map['user_id'] = _getCurrentUserId();
    return await db.update(
      'aktifitas_harian',
      map,
      where: 'id_aktifitas_harian = ?',
      whereArgs: [model.idAktifitasHarian],
    );
  }

  Future<int> deleteAktifitasHarian(int id) async {
    final db = await instance.database;
    return await db.delete(
      'aktifitas_harian',
      where: 'id_aktifitas_harian = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTodayTotalCalories() async {
    final db = await instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery(
      'SELECT SUM(total_kalori) as total FROM aktifitas_harian WHERE tanggal LIKE ? AND user_id = ?',
      ['$today%', _getCurrentUserId()],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<List<AktifitasHarianModel>> getAktifitasHarianByDate(String date) async {
    final db = await instance.database;
    final maps = await db.query(
      'aktifitas_harian',
      where: 'tanggal LIKE ? AND user_id = ?',
      whereArgs: ['$date%', _getCurrentUserId()],
      orderBy: 'id_aktifitas_harian DESC',
    );
    return maps.map((m) => AktifitasHarianModel.fromMap(m)).toList();
  }

  Future<List<Map<String, dynamic>>> getWeeklyWorkoutLogs() async {
    final db = await instance.database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String().substring(0, 10);

    // Using a virtual table WITH clause to join since jenis_aktifitas table was dropped
    final result = await db.rawQuery('''
      WITH jenis_aktifitas AS (
        SELECT id_jenis_aktifitas, nama_aktifitas, MET_aktifitas FROM arm_workout
        UNION ALL
        SELECT id_jenis_aktifitas, nama_aktifitas, MET_aktifitas FROM chest_workout
        UNION ALL
        SELECT id_jenis_aktifitas, nama_aktifitas, MET_aktifitas FROM leg_workout
        UNION ALL
        SELECT id_jenis_aktifitas, nama_aktifitas, MET_aktifitas FROM abs_workout
        UNION ALL
        SELECT id_jenis_aktifitas, nama_aktifitas, MET_aktifitas FROM cardio
      )
      SELECT a.*, j.nama_aktifitas, j.MET_aktifitas 
      FROM aktifitas_harian a
      LEFT JOIN jenis_aktifitas j ON a.id_jenis_aktifitas = j.id_jenis_aktifitas
      WHERE a.tanggal >= ? AND a.user_id = ?
    ''', [sevenDaysAgo, _getCurrentUserId()]);

    return result;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
