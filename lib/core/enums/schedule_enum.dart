// lib/core/enums/schedule_enum.dart
enum JadwalAktivitas {
  pagi('Pagi (06:00 - 09:00)'),
  siang('Siang (11:00 - 13:00)'),
  sore('Sore (15:00 - 17:00)'),
  malam('Malam (19:00 - 21:00)');

  final String label;
  const JadwalAktivitas(this.label);
}
