// Lokasi file: lib/core/models/aktifitas_harian_model.dart

/// Model untuk tabel aktifitas_harian.
/// Menyimpan catatan aktivitas harian pengguna beserta kalori yang terbakar.
class AktifitasHarianModel {
  final int? idAktifitasHarian; // null saat insert baru (AUTOINCREMENT)
  final String tanggal;
  final String idJenisAktifitas;
  final double totalKalori;
  final int durasiLatihan; // dalam menit
  final int? pace;
  final double? jarakTempuh;

  AktifitasHarianModel({
    this.idAktifitasHarian,
    required this.tanggal,
    required this.idJenisAktifitas,
    required this.totalKalori,
    required this.durasiLatihan,
    this.pace,
    this.jarakTempuh,
  });

  /// Convert model ke Map untuk SQLite insert.
  /// Tidak menyertakan idAktifitasHarian karena AUTOINCREMENT.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'tanggal': tanggal,
      'id_jenis_aktifitas': idJenisAktifitas,
      'total_kalori': totalKalori,
      'durasi_latihan': durasiLatihan,
      'pace': pace,
      'jarak_tempuh': jarakTempuh,
    };
    // Sertakan id hanya jika sudah ada (untuk update)
    if (idAktifitasHarian != null) {
      map['id_aktifitas_harian'] = idAktifitasHarian;
    }
    return map;
  }

  /// Convert Map dari SQLite ke AktifitasHarianModel.
  factory AktifitasHarianModel.fromMap(Map<String, dynamic> map) {
    return AktifitasHarianModel(
      idAktifitasHarian: map['id_aktifitas_harian'] as int?,
      tanggal: map['tanggal'] as String,
      idJenisAktifitas: map['id_jenis_aktifitas'] as String,
      totalKalori: (map['total_kalori'] as num?)?.toDouble() ?? 0.0,
      durasiLatihan: (map['durasi_latihan'] as int?) ?? 0,
      pace: map['pace'] as int?,
      jarakTempuh: (map['jarak_tempuh'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'AktifitasHarianModel(id: $idAktifitasHarian, tanggal: $tanggal, '
        'jenis: $idJenisAktifitas, kalori: $totalKalori, durasi: ${durasiLatihan}m)';
  }
}
