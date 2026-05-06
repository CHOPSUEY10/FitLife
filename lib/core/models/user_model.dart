// Lokasi file: lib/core/models/user_model.dart

class UserModel {
  final String id;
  final String nama;
  final double beratBadan; // Dalam Kilogram (kg), sangat penting untuk hitung kalori
  final double tinggiBadan; // Dalam Centimeter (cm)
  final int umur;

  UserModel({
    required this.id,
    required this.nama,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.umur,
  });

  // Contoh fungsi bawaan model (opsional)
  // Bisa digunakan jika teman tim Anda nanti butuh menghitung BMR
  double hitungBMR() {
    // Rumus dasar Mifflin-St Jeor (contoh untuk pria)
    return (10 * beratBadan) + (6.25 * tinggiBadan) - (5 * umur) + 5;
  }
}