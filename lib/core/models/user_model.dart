// Lokasi file: lib/core/models/user_model.dart

class UserModel {
  final String? id;
  final String? nama;
  final String? tanggalLahir; // Bisa berupa format 'YYYY-MM-DD'
  final double? tinggiBadan; // Dalam Centimeter (cm)
  final double? beratBadan; // Dalam Kilogram (kg)
  final String? jenisKelamin; // 'Pria' atau 'Wanita'
  final String? tujuan; // Tujuan gym (default, turun BB, naik massa)
  final String? waktuLuang; // Pilihan waktu luang (10-15m, dsb)
  final bool? isVerified; // Status verifikasi akun

  UserModel({
    this.id,
    this.nama,
    this.tanggalLahir,
    this.tinggiBadan,
    this.beratBadan,
    this.jenisKelamin,
    this.tujuan,
    this.waktuLuang,
    this.isVerified = false,
  });

  // Convert a UserModel into a Map for SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'tanggalLahir': tanggalLahir,
      'tinggiBadan': tinggiBadan,
      'beratBadan': beratBadan,
      'jenisKelamin': jenisKelamin,
      'tujuan': tujuan,
      'waktuLuang': waktuLuang,
      'isVerified': isVerified == true ? 1 : 0, // SQLite doesn't have a separate boolean storage class
    };
  }

  // Convert a Map from SQLite into a UserModel.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      nama: map['nama'],
      tanggalLahir: map['tanggalLahir'],
      tinggiBadan: map['tinggiBadan'],
      beratBadan: map['beratBadan'],
      jenisKelamin: map['jenisKelamin'],
      tujuan: map['tujuan'],
      waktuLuang: map['waktuLuang'],
      isVerified: map['isVerified'] == 1,
    );
  }
}