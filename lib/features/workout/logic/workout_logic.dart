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

    // 2. Get MET value for this activity type (now returns a Map from one of the 5 tables)
    final jenisAktifitas = await _dbHelper.getWorkoutActivityById(idJenisAktifitas);
    if (jenisAktifitas == null) return 0.0;

    // 3. Calculate calories
    final double totalKalori = calculateCalories(
      met: (jenisAktifitas['MET_aktifitas'] as num).toDouble(),
      weightKg: weightKg,
      durationMinutes: durasiLatihan,
    );

    // 4. Build model and persist to aktifitas_harian
    final record = AktifitasHarianModel(
      tanggal: DateTime.now().toIso8601String(),
      idJenisAktifitas: idJenisAktifitas,
      totalKalori: totalKalori,
      durasiLatihan: durasiLatihan,
      pace: pace,
      jarakTempuh: jarakTempuh,
    );
    await _dbHelper.insertAktifitasHarian(record);

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
