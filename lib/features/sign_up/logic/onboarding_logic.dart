import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/user_model.dart';
import '../../../core/database/local_db_helper.dart';

class OnboardingLogic {
  // Method to save the data captured in the onboarding screens
  Future<void> saveOnboardingData({
    required String? tujuan,
    required String? tanggalLahir,
    required double? tinggiBadan,
    required double? beratBadan,
    required String? jenisKelamin,
    required String? waktuLuang,
  }) async {
    try {
      // First, fetch existing user data if any, so we don't overwrite with nulls
      // if saving from different steps.
      UserModel? existingUser = await LocalDBHelper.instance.getUserMetrics();

      UserModel updatedUser = UserModel(
        id: 'local_user', // Fixed ID for single local profile
        tujuan: tujuan ?? existingUser?.tujuan,
        tanggalLahir: tanggalLahir ?? existingUser?.tanggalLahir,
        tinggiBadan: tinggiBadan ?? existingUser?.tinggiBadan,
        beratBadan: beratBadan ?? existingUser?.beratBadan,
        jenisKelamin: jenisKelamin ?? existingUser?.jenisKelamin,
        waktuLuang: waktuLuang ?? existingUser?.waktuLuang,
        isVerified: existingUser?.isVerified ?? true, // Users in onboarding are already OTP-verified
      );

      // Save to SQLite
      await LocalDBHelper.instance.saveUserMetrics(updatedUser);
      debugPrint('Successfully saved user data: ${updatedUser.toMap()}');
    } catch (e) {
      // Typically we'd use core/errors/failures.dart here. 
      // For now we rethrow the exception or handle appropriately.
      debugPrint('Error saving onboarding data: $e');
      throw Exception('Gagal menyimpan data: $e');
    }
  }

  /// Saves user's chosen level of activity during onboarding to SharedPreferences
  Future<void> saveLevelAktivitas(String level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('levelAktivitas', level);
      debugPrint('Successfully saved onboarding levelAktivitas: $level');
    } catch (e) {
      debugPrint('Error saving onboarding levelAktivitas: $e');
      throw Exception('Gagal menyimpan level aktivitas: $e');
    }
  }
}
