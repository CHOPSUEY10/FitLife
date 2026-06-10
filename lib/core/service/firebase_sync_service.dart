import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../database/local_db_helper.dart';
import '../models/user_model.dart';
import '../utils/target_calculator.dart';

class FirebaseSyncService {
  static final FirebaseSyncService instance = FirebaseSyncService._();
  FirebaseSyncService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Syncs local database user data and activity level to Cloud Firestore
  Future<void> syncUserData({bool force = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('FirebaseSync: No logged-in user. Skipping sync.');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final lastSyncMs = prefs.getInt('last_firebase_sync_timestamp') ?? 0;
      final currentTimeMs = DateTime.now().millisecondsSinceEpoch;
      
      // 1 week = 7 days * 24 hours * 60 minutes * 60 seconds * 1000 milliseconds
      const oneWeekMs = 7 * 24 * 60 * 60 * 1000;

      if (!force && (currentTimeMs - lastSyncMs < oneWeekMs)) {
        debugPrint('FirebaseSync: Last sync was less than a week ago. Skipping.');
        return;
      }

      // Fetch user metrics from SQLite
      final UserModel? localUser = await LocalDBHelper.instance.getUserMetrics();
      if (localUser == null) {
        debugPrint('FirebaseSync: No local user metrics to sync.');
        return;
      }

      final levelAktivitas = prefs.getString('levelAktivitas') ?? 'Pemula';
      final target = await LocalDBHelper.instance.getTargetHarian();

      // Prepare sync map
      final Map<String, dynamic> syncData = {
        'uid': user.uid,
        'email': user.email,
        'nama': localUser.nama ?? user.displayName ?? '',
        'tanggalLahir': localUser.tanggalLahir,
        'tinggiBadan': localUser.tinggiBadan,
        'beratBadan': localUser.beratBadan,
        'jenisKelamin': localUser.jenisKelamin,
        'tujuan': localUser.tujuan,
        'waktuLuang': localUser.waktuLuang,
        'levelAktivitas': levelAktivitas,
        'targetLangkah': target.targetLangkah,
        'targetKalori': target.targetKalori,
        'targetDurasiLatihan': target.targetDurasiLatihan,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      };

      // Upload to Firestore users collection
      await _firestore.collection('users').doc(user.uid).set(syncData, SetOptions(merge: true));
      
      // Save last sync time
      await prefs.setInt('last_firebase_sync_timestamp', currentTimeMs);
      debugPrint('FirebaseSync: Successfully synced user data to Firebase Firestore.');
    } catch (e) {
      debugPrint('FirebaseSync Error: $e');
    }
  }

  /// Attempts to restore user data from Firestore to the local SQLite database.
  /// Returns true if data was successfully restored, false if no data exists.
  Future<bool> restoreUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        
        // Ensure that required fields (like tinggiBadan) actually exist before restoring
        if (data['tinggiBadan'] != null) {
          final restoredUser = UserModel(
            id: user.uid,
            nama: data['nama'],
            tanggalLahir: data['tanggalLahir'],
            tinggiBadan: (data['tinggiBadan'] as num?)?.toDouble(),
            beratBadan: (data['beratBadan'] as num?)?.toDouble(),
            jenisKelamin: data['jenisKelamin'],
            tujuan: data['tujuan'],
            waktuLuang: data['waktuLuang'],
            isVerified: true,
          );

          await LocalDBHelper.instance.saveUserMetrics(restoredUser);
          
          if (data['levelAktivitas'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('levelAktivitas', data['levelAktivitas']);
          }
          
          // RECALCULATE TARGET HARIAN AFTER RESTORE
          await TargetCalculator.calculateAndSaveTargetHarian();
          
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('FirebaseSync Restore Error: $e');
      return false;
    }
  }
}
