import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/aktifitas_harian_model.dart';
import '../models/arm_workout_model.dart';
import '../models/chest_workout_model.dart';
import '../models/leg_workout_model.dart';
import '../models/abs_workout_model.dart';
import '../models/cardio_model.dart';

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
      version: 4,
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
        jarak_tempuh REAL
      )
    ''');

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
      // Create 5 new tables
      await _createWorkoutTables(db);
      
      // We drop the FK constraint on aktifitas_harian by recreating the table and copying data
      // (SQLite doesn't support DROP CONSTRAINT easily)
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
      
      // Optionally drop the old jenis_aktifitas table
      await db.execute('DROP TABLE IF EXISTS jenis_aktifitas');

      // Seed the newly extracted UI data
      await _seedWorkoutData(db);
    }
  }

  /// Seed the 5 workout tables with extracted data from UI screens
  Future<void> _seedWorkoutData(Database db) async {
    // 1. Arm Workout (MET: 3.5)
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

    // 2. Chest Workout (MET: 3.8)
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

    // 3. Leg Workout (MET: 5.0)
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

    // 4. Abs Workout (MET: 4.0)
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

    // 5. Cardio (MET: 7.0)
    final cardio = [
      CardioModel(idJenisAktifitas: 'cardio_01', namaAktifitas: 'Jogging / Lari', metAktifitas: 7.0),
    ];
    for (var w in cardio) {
      await db.insert('cardio', w.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // ─── Users CRUD ─────────────────────────────────────────────

  Future<void> saveUserMetrics(UserModel user) async {
    final db = await instance.database;
    // We use id 'local_user' to always replace the same local profile during onboarding
    final userMap = user.toMap();
    userMap['id'] = 'local_user'; 
    
    await db.insert(
      'users',
      userMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUserMetrics() async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: ['local_user'],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // ─── Aktifitas Harian CRUD ──────────────────────────────────

  /// Get the list of workout categories (muscle groups)
  Future<List<String>> getWorkoutCategories() async {
    // Returning the formatted names of our 5 tables
    return ['Arm Workout', 'Chest Workout', 'Leg Workout', 'Abs Workout', 'Cardio'];
  }

  /// Get all recorded activity dates for a specific year and month
  Future<List<DateTime>> getAktifitasDatesForMonth(int year, int month) async {
    final db = await instance.database;
    final monthStr = month.toString().padLeft(2, '0');
    final queryStr = '$year-$monthStr%';
    
    final results = await db.rawQuery(
      'SELECT DISTINCT tanggal FROM aktifitas_harian WHERE tanggal LIKE ?',
      [queryStr]
    );

    return results.map((r) => DateTime.parse(r['tanggal'] as String)).toList();
  }



  /// Get a combined list of all workout names across the 5 tables
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

  /// Find an activity by its ID by searching across all 5 workout tables
  Future<Map<String, dynamic>?> getWorkoutActivityById(String id) async {
    final db = await instance.database;
    final tables = ['arm_workout', 'chest_workout', 'leg_workout', 'abs_workout', 'cardio'];
    
    for (var table in tables) {
      final results = await db.query(table, where: 'id_jenis_aktifitas = ?', whereArgs: [id]);
      if (results.isNotEmpty) return results.first;
    }
    return null;
  }

  /// Insert a daily activity record from model
  Future<int> insertAktifitasHarian(AktifitasHarianModel model) async {
    final db = await instance.database;
    return await db.insert('aktifitas_harian', model.toMap());
  }

  /// Update an existing daily activity record
  Future<int> updateAktifitasHarian(AktifitasHarianModel model) async {
    final db = await instance.database;
    return await db.update(
      'aktifitas_harian',
      model.toMap(),
      where: 'id_aktifitas_harian = ?',
      whereArgs: [model.idAktifitasHarian],
    );
  }

  /// Delete a daily activity record
  Future<int> deleteAktifitasHarian(int id) async {
    final db = await instance.database;
    return await db.delete(
      'aktifitas_harian',
      where: 'id_aktifitas_harian = ?',
      whereArgs: [id],
    );
  }

  /// Get the total calories burned today
  Future<double> getTodayTotalCalories() async {
    final db = await instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10); // 'YYYY-MM-DD'
    final result = await db.rawQuery(
      'SELECT SUM(total_kalori) as total FROM aktifitas_harian WHERE tanggal LIKE ?',
      ['$today%'],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  /// Get all daily activities for a specific date (format: 'YYYY-MM-DD') as typed models
  Future<List<AktifitasHarianModel>> getAktifitasHarianByDate(String date) async {
    final db = await instance.database;
    final maps = await db.query(
      'aktifitas_harian',
      where: 'tanggal LIKE ?',
      whereArgs: ['$date%'],
      orderBy: 'id_aktifitas_harian DESC',
    );
    return maps.map((m) => AktifitasHarianModel.fromMap(m)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
