import '../../../core/enums/schedule_enum.dart';
import 'settings_controller.dart';

class RecommendationService {
  static List<Map<String, dynamic>> getRecommendations({
    required SettingsController settings,
    required List<String> availableMuscles,
    required List<JadwalAktivitas> availableSchedules,
  }) {
    if (availableSchedules.isEmpty || availableMuscles.isEmpty) return [];

    // Pilih jadwal pertama yang tersedia
    final schedule = availableSchedules.first;
    List<Map<String, dynamic>> recommendations = [];

    // Deteksi dari pengaturan user
    bool isOverweight = settings.bmiKategori == 'Kelebihan Berat' || settings.bmiKategori == 'Obesitas';
    bool isShortTime = settings.waktuLuang.contains('< 15') || settings.waktuLuang.contains('15 - 30');
    bool isBeginner = settings.levelAktivitas.toLowerCase() == 'pemula';

    // Helper untuk mencari aktivitas yang paling cocok (case insensitive)
    String findActivity(List<String> keywords, String fallback) {
      for (var kw in keywords) {
        try {
          final match = availableMuscles.firstWhere(
            (m) => m.toLowerCase().contains(kw.toLowerCase()),
          );
          return match;
        } catch (_) {}
      }
      return availableMuscles.contains(fallback) ? fallback : availableMuscles.first;
    }

    // Rekomendasi 1: Berdasarkan BMI
    if (isOverweight) {
      recommendations.add({
        'title': 'Pembakar Lemak 🔥',
        'muscle': findActivity(['kardio', 'lari', 'hiit', 'seluruh'], 'Kardio'),
        'schedule': schedule,
      });
    } else {
      recommendations.add({
        'title': 'Pembentuk Otot 💪',
        'muscle': findActivity(['dada', 'punggung', 'kaki'], 'Otot Dada'),
        'schedule': schedule,
      });
    }

    // Rekomendasi 2: Berdasarkan Waktu Luang
    if (isShortTime) {
      recommendations.add({
        'title': 'Sesi Cepat ⚡',
        'muscle': findActivity(['seluruh', 'kardio', 'pemanasan'], 'Seluruh Tubuh'),
        'schedule': schedule,
      });
    } else {
      recommendations.add({
        'title': 'Sesi Intensif 🏆',
        'muscle': findActivity(['kaki', 'punggung', 'dada'], 'Otot Kaki'),
        'schedule': schedule,
      });
    }

    // Rekomendasi 3: Berdasarkan Level Aktivitas
    if (isBeginner) {
      recommendations.add({
        'title': 'Ringan & Aman 🌱',
        'muscle': findActivity(['pemanasan', 'seluruh', 'kardio'], 'Pemanasan'),
        'schedule': availableSchedules.last, 
      });
    } else {
      recommendations.add({
        'title': 'Kekuatan Inti 🏋️',
        'muscle': findActivity(['lengan', 'punggung', 'dada'], 'Lengan'),
        'schedule': availableSchedules.last,
      });
    }

    // Buang duplikasi jika ada aktivitas (muscle) yang sama
    final uniqueRecs = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (var rec in recommendations) {
      if (!seen.contains(rec['muscle'])) {
        seen.add(rec['muscle']);
        uniqueRecs.add(rec);
      }
    }

    return uniqueRecs.take(3).toList();
  }
}
