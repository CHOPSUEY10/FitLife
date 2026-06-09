// Lokasi file: lib/core/models/jenis_aktifitas_model.dart

/// Model untuk tabel jenis_aktifitas.
/// Menyimpan data jenis aktivitas beserta nilai MET-nya.
class JenisAktifitasModel {
  final String idJenisAktifitas;
  final String namaAktifitas;
  final double metAktifitas;

  JenisAktifitasModel({
    required this.idJenisAktifitas,
    required this.namaAktifitas,
    required this.metAktifitas,
  });

  /// Convert model ke Map untuk SQLite insert/update.
  Map<String, dynamic> toMap() {
    return {
      'id_jenis_aktifitas': idJenisAktifitas,
      'nama_aktifitas': namaAktifitas,
      'MET_aktifitas': metAktifitas,
    };
  }

  /// Convert Map dari SQLite ke JenisAktifitasModel.
  factory JenisAktifitasModel.fromMap(Map<String, dynamic> map) {
    return JenisAktifitasModel(
      idJenisAktifitas: map['id_jenis_aktifitas'] as String,
      namaAktifitas: map['nama_aktifitas'] as String,
      metAktifitas: (map['MET_aktifitas'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'JenisAktifitasModel(id: $idJenisAktifitas, nama: $namaAktifitas, MET: $metAktifitas)';
  }
}
