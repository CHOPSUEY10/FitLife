// Lokasi: lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  Failure(this.message);
}

// Khusus untuk error yang berhubungan dengan GPS
class LocationFailure extends Failure {
  LocationFailure(super.message);
}

// Khusus untuk error saat menyimpan data
class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}