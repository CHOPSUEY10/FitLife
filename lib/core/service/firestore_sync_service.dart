import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSyncService {
  static final FirestoreSyncService instance = FirestoreSyncService._();
  FirestoreSyncService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> pushWeeklyData(String uid, List<Map<String, dynamic>> weeklyLogs) async {
    final collectionRef = _firestore.collection('users').doc(uid).collection('weekly_syncs');
    
    // Save the weekly logs as a single document with a timestamp
    final syncDoc = collectionRef.doc(DateTime.now().toIso8601String());
    
    await syncDoc.set({
      'syncedAt': FieldValue.serverTimestamp(),
      'logs': weeklyLogs,
    });
  }
}
