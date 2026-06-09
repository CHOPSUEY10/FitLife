// lib/features/dashboard/logic/settings_controller.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/local_db_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/target_harian_model.dart';

class SettingsController extends ChangeNotifier {
  // ── User profile & physical data ──────────────────────────
  String nama = '';
  String tanggalLahir = '';
  String jenisKelamin = 'Pria';
  double tinggiBadan = 170;
  double beratBadan = 65;

  // ── Tujuan ────────────────────────────────────────────────
  String tujuan = 'Turun Berat Badan';

  // ── Waktu Luang ───────────────────────────────────────────
  String waktuLuang = '30 - 45 menit';

  // ── Level Aktivitas ───────────────────────────────────────
  String levelAktivitas = 'Pemula';

  // ── Target Harian ─────────────────────────────────────────
  int targetLangkah = 8000;
  double targetKalori = 500;
  int targetDurasiLatihan = 45; // menit

  // ── Notifikasi ────────────────────────────────────────────
  bool notifPengingat = true;
  bool notifPencapaian = true;
  bool notifTips = false;
  String waktuPengingat = '07:00';

  // ── Pengaturan Umum ───────────────────────────────────────
  String bahasa = 'Indonesia';
  String unitBerat = 'kg';
  String unitTinggi = 'cm';
  bool modeMalam = true;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SettingsController() {
    loadAll();
  }

  /// Load semua data dari DB & SharedPreferences
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadFromPrefs();
      await _loadFromDB();
    } catch (e) {
      debugPrint('SettingsController loadAll error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFromDB() async {
    final user = await LocalDBHelper.instance.getUserMetrics();
    if (user != null) {
      nama = user.nama ?? '';
      tanggalLahir = user.tanggalLahir ?? '';
      jenisKelamin = user.jenisKelamin ?? 'Pria';
      tinggiBadan = user.tinggiBadan ?? 170;
      beratBadan = user.beratBadan ?? 65;
      tujuan = user.tujuan ?? 'Turun Berat Badan';
      waktuLuang = user.waktuLuang ?? '30 - 45 menit';
    }

    final target = await LocalDBHelper.instance.getTargetHarian();
    targetLangkah = target.targetLangkah;
    targetKalori = target.targetKalori;
    targetDurasiLatihan = target.targetDurasiLatihan;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    levelAktivitas = prefs.getString('levelAktivitas') ?? 'Pemula';
    targetLangkah = prefs.getInt('targetLangkah') ?? 8000;
    targetKalori = prefs.getDouble('targetKalori') ?? 500;
    targetDurasiLatihan = prefs.getInt('targetDurasiLatihan') ?? 45;
    notifPengingat = prefs.getBool('notifPengingat') ?? true;
    notifPencapaian = prefs.getBool('notifPencapaian') ?? true;
    notifTips = prefs.getBool('notifTips') ?? false;
    waktuPengingat = prefs.getString('waktuPengingat') ?? '07:00';
    bahasa = prefs.getString('bahasa') ?? 'Indonesia';
    unitBerat = prefs.getString('unitBerat') ?? 'kg';
    unitTinggi = prefs.getString('unitTinggi') ?? 'cm';
    modeMalam = prefs.getBool('modeMalam') ?? true;
  }

  // ── Save helpers ──────────────────────────────────────────

  Future<void> saveProfil({
    required String namaBaru,
    required String tanggalLahirBaru,
    required String jenisKelaminBaru,
  }) async {
    nama = namaBaru;
    tanggalLahir = tanggalLahirBaru;
    jenisKelamin = jenisKelaminBaru;
    await _saveToDBUser();
    notifyListeners();
  }

  Future<void> saveDataFisik({
    required double tinggi,
    required double berat,
  }) async {
    tinggiBadan = tinggi;
    beratBadan = berat;
    await _saveToDBUser();
    notifyListeners();
  }

  Future<void> saveTujuan(String tujuanBaru) async {
    tujuan = tujuanBaru;
    await _saveToDBUser();
    notifyListeners();
  }

  Future<void> saveWaktuLuang(String waktuBaru) async {
    waktuLuang = waktuBaru;
    await _saveToDBUser();
    notifyListeners();
  }

  Future<void> saveLevelAktivitas(String level) async {
    levelAktivitas = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('levelAktivitas', levelAktivitas);
    notifyListeners();
  }

  Future<void> saveTargetHarian({
    required int langkah,
    required double kalori,
    required int durasi,
  }) async {
    targetLangkah = langkah;
    targetKalori = kalori;
    targetDurasiLatihan = durasi;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('targetLangkah', langkah);
    await prefs.setDouble('targetKalori', kalori);
    await prefs.setInt('targetDurasiLatihan', durasi);

    final targetModel = TargetHarianModel(
      id: 'local_target',
      targetLangkah: langkah,
      targetKalori: kalori,
      targetDurasiLatihan: durasi,
    );
    await LocalDBHelper.instance.saveTargetHarian(targetModel);

    notifyListeners();
  }

  Future<void> saveNotifikasi({
    required bool pengingat,
    required bool pencapaian,
    required bool tips,
    required String waktu,
  }) async {
    notifPengingat = pengingat;
    notifPencapaian = pencapaian;
    notifTips = tips;
    waktuPengingat = waktu;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifPengingat', pengingat);
    await prefs.setBool('notifPencapaian', pencapaian);
    await prefs.setBool('notifTips', tips);
    await prefs.setString('waktuPengingat', waktu);
    notifyListeners();
  }

  Future<void> savePengaturanUmum({
    required String bahasaBaru,
    required String unitBeratBaru,
    required String unitTinggiBaru,
    required bool malam,
  }) async {
    bahasa = bahasaBaru;
    unitBerat = unitBeratBaru;
    unitTinggi = unitTinggiBaru;
    modeMalam = malam;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bahasa', bahasa);
    await prefs.setString('unitBerat', unitBerat);
    await prefs.setString('unitTinggi', unitTinggi);
    await prefs.setBool('modeMalam', modeMalam);
    notifyListeners();
  }

  Future<void> _saveToDBUser() async {
    final user = UserModel(
      id: 'local_user',
      nama: nama,
      tanggalLahir: tanggalLahir,
      jenisKelamin: jenisKelamin,
      tinggiBadan: tinggiBadan,
      beratBadan: beratBadan,
      tujuan: tujuan,
      waktuLuang: waktuLuang,
    );
    await LocalDBHelper.instance.saveUserMetrics(user);
  }

  // ── Computed helpers ──────────────────────────────────────

  double get bmi {
    if (tinggiBadan <= 0) return 0;
    final tinggiM = tinggiBadan / 100;
    return beratBadan / (tinggiM * tinggiM);
  }

  String get bmiKategori {
    final b = bmi;
    if (b < 18.5) return 'Kurus';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Kelebihan Berat';
    return 'Obesitas';
  }
}
