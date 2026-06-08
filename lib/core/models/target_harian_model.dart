// Lokasi: lib/core/models/target_harian_model.dart

class TargetHarianModel {
  final String id;
  final int targetLangkah;
  final double targetKalori;
  final int targetDurasiLatihan; // Dalam menit

  TargetHarianModel({
    required this.id,
    required this.targetLangkah,
    required this.targetKalori,
    required this.targetDurasiLatihan,
  });

  // Convert a TargetHarianModel into a Map for SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetLangkah': targetLangkah,
      'targetKalori': targetKalori,
      'targetDurasiLatihan': targetDurasiLatihan,
    };
  }

  // Convert a Map from SQLite into a TargetHarianModel.
  factory TargetHarianModel.fromMap(Map<String, dynamic> map) {
    return TargetHarianModel(
      id: map['id'] ?? 'local_target',
      targetLangkah: map['targetLangkah'] ?? 8000,
      targetKalori: (map['targetKalori'] as num?)?.toDouble() ?? 500.0,
      targetDurasiLatihan: map['targetDurasiLatihan'] ?? 45,
    );
  }
}
