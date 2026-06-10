import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/database/local_db_helper.dart';
import '../../../core/service/firestore_sync_service.dart';

class SyncController {
  static final SyncController instance = SyncController._();
  SyncController._();

  Future<void> runWeeklySync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncDateStr = prefs.getString('last_sync_date');
      
      bool shouldSync = false;
      if (lastSyncDateStr == null) {
        shouldSync = true;
      } else {
        final lastSyncDate = DateTime.parse(lastSyncDateStr);
        if (DateTime.now().difference(lastSyncDate).inDays >= 7) {
          shouldSync = true;
        }
      }

      if (shouldSync) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final weeklyLogs = await LocalDBHelper.instance.getWeeklyWorkoutLogs();
        if (weeklyLogs.isNotEmpty) {
          await FirestoreSyncService.instance.pushWeeklyData(user.uid, weeklyLogs);
        }
        
        await prefs.setString('last_sync_date', DateTime.now().toIso8601String());
        debugPrint('Weekly sync completed successfully.');
      }
    } catch (e) {
      debugPrint('Error during weekly sync: $e');
    }
  }
}
