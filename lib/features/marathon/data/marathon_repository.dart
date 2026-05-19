import '../../../core/database/local_db_helper.dart';
import '../../../core/models/cardio_model.dart';

class MarathonRepository {
  /// Fetches the default cardio data from the database.
  Future<CardioModel?> getCardioData() async {
    final db = await LocalDBHelper.instance.database;
    final results = await db.query('cardio');
    if (results.isNotEmpty) {
      return CardioModel.fromMap(results.first);
    }
    return null;
  }
}
