// Lokasi file: lib/core/utils/time_formatter.dart

class TimeFormatter {
  /// Mengubah total detik menjadi format HH:MM:SS
  static String formatDuration(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return "$hoursStr:$minutesStr:$secondsStr";
    } else {
      // Jika belum sampai 1 jam, tampilkan MM:SS saja
      return "$minutesStr:$secondsStr";
    }
  }
}