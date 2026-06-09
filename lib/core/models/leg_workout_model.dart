// Lokasi file: lib/core/models/leg_workout_model.dart

class LegWorkoutModel {
  final String idJenisAktifitas;
  final String namaAktifitas;
  final double metAktifitas;
  final int? durasi;
  final int? reps;
  final int? pace;
  final double? jarakTempuh;

  LegWorkoutModel({
    required this.idJenisAktifitas,
    required this.namaAktifitas,
    required this.metAktifitas,
    this.durasi,
    this.reps,
    this.pace,
    this.jarakTempuh,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_jenis_aktifitas': idJenisAktifitas,
      'nama_aktifitas': namaAktifitas,
      'MET_aktifitas': metAktifitas,
      'durasi': durasi,
      'reps': reps,
      'pace': pace,
      'jarak_tempuh': jarakTempuh,
    };
  }

  factory LegWorkoutModel.fromMap(Map<String, dynamic> map) {
    return LegWorkoutModel(
      idJenisAktifitas: map['id_jenis_aktifitas'] as String,
      namaAktifitas: map['nama_aktifitas'] as String,
      metAktifitas: (map['MET_aktifitas'] as num).toDouble(),
      durasi: map['durasi'] as int?,
      reps: map['reps'] as int?,
      pace: map['pace'] as int?,
      jarakTempuh: (map['jarak_tempuh'] as num?)?.toDouble(),
    );
  }
}
