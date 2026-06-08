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

// Khusus untuk error OTP
class InvalidOtpFailure extends Failure {
  InvalidOtpFailure([super.message = "Invalid OTP"]);
}

class ExpiredOtpFailure extends Failure {
  ExpiredOtpFailure([super.message = "Expired OTP"]);
}

// Khusus untuk error autentikasi dan akun
class AuthFailure extends Failure {
  AuthFailure(super.message);
}

class RequiresRecentLoginFailure extends AuthFailure {
  RequiresRecentLoginFailure([super.message = "Sesi Anda memerlukan verifikasi ulang untuk alasan keamanan."]);
}