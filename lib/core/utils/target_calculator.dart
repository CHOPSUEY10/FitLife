import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/target_harian_model.dart';
import '../database/local_db_helper.dart';

class TargetCalculator {
  /// Calculates and saves dynamic targets (Langkah, Kalori, Durasi) based on user's current physical metrics
  static Future<void> calculateAndSaveTargetHarian() async {
    try {
      final user = await LocalDBHelper.instance.getUserMetrics();
      // If user profile is not complete enough for medical calculation, gracefully exit or fallback
      if (user == null || user.beratBadan == null || user.tinggiBadan == null || user.tanggalLahir == null) {
        debugPrint('TargetCalculator: Insufficient data to calculate BMR/TDEE. Skipping.');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final level = prefs.getString('levelAktivitas') ?? 'Pemula';
      final waktuLuang = user.waktuLuang ?? '10 - 15 menit';
      
      // 1. Calculate Age
      final parts = user.tanggalLahir!.split('/');
      int age = 25; // default fallback
      if (parts.length == 3) {
        final birthYear = int.tryParse(parts[2]);
        if (birthYear != null) {
          age = DateTime.now().year - birthYear;
        }
      }
      
      // 2. Calculate BMR (Mifflin-St Jeor)
      double bmr = 0;
      if (user.jenisKelamin?.toLowerCase() == 'wanita') {
        bmr = (10 * user.beratBadan!) + (6.25 * user.tinggiBadan!) - (5 * age) - 161;
      } else {
        bmr = (10 * user.beratBadan!) + (6.25 * user.tinggiBadan!) - (5 * age) + 5;
      }
      
      // 3. Calculate TDEE
      double tdeeMultiplier = 1.2; // Pemula
      if (level.toLowerCase() == 'menengah') tdeeMultiplier = 1.55;
      if (level.toLowerCase().contains('mahir') || level.toLowerCase().contains('atlet')) tdeeMultiplier = 1.9;
      
      double tdee = bmr * tdeeMultiplier;
      
      // 4. Target Kalori Aktif
      // Roughly 15% of TDEE should be burned via structured active exercise
      double targetKalori = tdee * 0.15;
      
      // 5. Target Durasi
      int targetDurasi = 15;
      if (waktuLuang.contains('5 - 10')) targetDurasi = 10;
      if (waktuLuang.contains('10 - 15')) targetDurasi = 15;
      if (waktuLuang.contains('> 15')) targetDurasi = 20;
      
      // 6. Target Langkah
      int targetLangkah = 5000;
      if (level.toLowerCase() == 'menengah') targetLangkah = 8000;
      if (level.toLowerCase().contains('mahir') || level.toLowerCase().contains('atlet')) targetLangkah = 12000;
      
      // Save to SQLite target_harian table
      final target = TargetHarianModel(
        id: 'local_target', // This will be automatically overridden by FirebaseAuth UID inside LocalDBHelper
        targetLangkah: targetLangkah,
        targetKalori: targetKalori,
        targetDurasiLatihan: targetDurasi,
      );
      await LocalDBHelper.instance.saveTargetHarian(target);
      
      // Save to SharedPreferences for fast reactive UI access via SettingsController
      await prefs.setInt('targetLangkah', targetLangkah);
      await prefs.setDouble('targetKalori', targetKalori);
      await prefs.setInt('targetDurasiLatihan', targetDurasi);
      
      debugPrint('TargetCalculator: Dynamic Targets Recalculated! Kalori=$targetKalori, Langkah=$targetLangkah, Durasi=$targetDurasi');
    } catch (e) {
      debugPrint('TargetCalculator Error: $e');
    }
  }
}
