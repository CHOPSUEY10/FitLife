import '../../../core/database/local_db_helper.dart';
import '../../../core/models/aktifitas_harian_model.dart';

/// Business logic for workout calorie calculation and persistence.
///
/// Uses the MET (Metabolic Equivalent of Task) formula:
///   Calories = MET × Weight(kg) × Duration(hours)
class WorkoutLogic {
  final LocalDBHelper _dbHelper = LocalDBHelper.instance;

  // ─── Calorie Calculation ──────────────────────────────────

  /// Pure calculation: returns calories burned.
  ///
  /// [met] — Metabolic Equivalent value for the activity
  /// [weightKg] — User's body weight in kilograms
  /// [durationMinutes] — Duration of the activity in minutes
  static double calculateCalories({
    required double met,
    required double weightKg,
    required int durationMinutes,
  }) {
    return met * weightKg * (durationMinutes / 60.0);
  }

  // ─── Persistence ──────────────────────────────────────────

  /// Calculate and save a completed workout to the database.
  ///
  /// Fetches the user's weight from the DB, looks up the MET value
  /// for [idJenisAktifitas], calculates calories, and inserts the record
  /// as an [AktifitasHarianModel].
  ///
  /// Returns the calculated calorie value, or 0.0 if activity type not found.
  Future<double> saveWorkoutRecord({
    required String idJenisAktifitas,
    required int durasiLatihan,
    int? pace,
    double? jarakTempuh,
  }) async {
    // 1. Get user weight
    final user = await _dbHelper.getUserMetrics();
    final double weightKg = user?.beratBadan ?? 70.0; // default 70kg if not set

    // 2. Get MET value and standard category name
    double met = 4.0;
    String dbCategory = idJenisAktifitas;

    final lowerId = idJenisAktifitas.toLowerCase();
    if (lowerId.contains('abs')) { met = 4.0; dbCategory = 'Abs Workout'; }
    else if (lowerId.contains('chest')) { met = 3.8; dbCategory = 'Chest Workout'; }
    else if (lowerId.contains('arm')) { met = 3.5; dbCategory = 'Arm Workout'; }
    else if (lowerId.contains('leg')) { met = 5.0; dbCategory = 'Leg Workout'; }
    else if (lowerId.contains('jog') || lowerId.contains('cardio')) { met = 7.0; dbCategory = 'Cardio'; }

    // 3. Calculate calories
    final double totalKalori = calculateCalories(
      met: met,
      weightKg: weightKg,
      durationMinutes: durasiLatihan,
    );

    // 4. Update existing schedule for today, or Insert new
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final activities = await _dbHelper.getAktifitasHarianByDate(today);
    
    AktifitasHarianModel? existingSchedule;
    try {
      existingSchedule = activities.firstWhere((a) => a.idJenisAktifitas == dbCategory);
    } catch (e) {
      existingSchedule = null;
    }

    if (existingSchedule != null) {
      // UPDATE existing record
      final updatedModel = AktifitasHarianModel(
        idAktifitasHarian: existingSchedule.idAktifitasHarian,
        tanggal: existingSchedule.tanggal,
        idJenisAktifitas: dbCategory,
        // If it's a schedule (kalori == 0), replace it. Otherwise, add to it.
        totalKalori: (existingSchedule.totalKalori == 0) ? totalKalori : ((existingSchedule.totalKalori ?? 0) + totalKalori),
        durasiLatihan: (existingSchedule.durasiLatihan == 0) ? durasiLatihan : ((existingSchedule.durasiLatihan ?? 0) + durasiLatihan),
        pace: pace ?? existingSchedule.pace,
        jarakTempuh: jarakTempuh ?? existingSchedule.jarakTempuh,
      );
      await _dbHelper.updateAktifitasHarian(updatedModel);
    } else {
      // INSERT new record
      final record = AktifitasHarianModel(
        tanggal: DateTime.now().toIso8601String(),
        idJenisAktifitas: dbCategory,
        totalKalori: totalKalori,
        durasiLatihan: durasiLatihan,
        pace: pace,
        jarakTempuh: jarakTempuh,
      );
      await _dbHelper.insertAktifitasHarian(record);
    }

    return totalKalori;
  }

  // ─── Queries ──────────────────────────────────────────────

  /// Get the total calories burned today (sum across all activities).
  Future<double> getTodayCalories() async {
    return await _dbHelper.getTodayTotalCalories();
  }

  /// Get all activity records for a specific date as typed models.
  Future<List<AktifitasHarianModel>> getActivitiesByDate(String date) async {
    return await _dbHelper.getAktifitasHarianByDate(date);
  }
}
