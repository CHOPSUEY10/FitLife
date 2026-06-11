// Lokasi: lib/features/workout/logic/workout_generator.dart

/// Generator latihan dinamis yang menyesuaikan jumlah gerakan, repetisi, 
/// dan durasi berdasarkan profil pengguna (Level Aktivitas & Waktu Luang).
class WorkoutGenerator {
  // =========================================================================
  // MASTER DATA POOL LATIHAN
  // Berisi semua daftar gerakan yang tersedia untuk setiap bagian tubuh.
  // =========================================================================
  
  static final List<Map<String, dynamic>> _legExercises = [
    {
      'name': 'Squat',
      'repsBase': 15, // Repetisi dasar (akan dimodifikasi sesuai level)
      'durationBase': 40, // Durasi dasar (detik)
      'image': 'assets/illustration/plank.webp',
      'description': 'Berdiri selebar bahu, tekuk lutut turunkan pinggul lalu kembali berdiri.',
      'tip': 'Lutut tidak melewati ujung kaki',
    },
    {
      'name': 'Lunge',
      'repsBase': 12,
      'durationBase': 45,
      'image': 'assets/illustration/plank.webp',
      'description': 'Langkah maju, tekuk kedua lutut 90°, lalu kembali ke posisi awal.',
      'tip': 'Jaga tubuh tetap tegak',
    },
    {
      'name': 'Calf Raise',
      'repsBase': 20,
      'durationBase': 30,
      'image': 'assets/illustration/plank.webp',
      'description': 'Berdiri tegak, angkat tumit setinggi mungkin lalu turunkan perlahan.',
      'tip': 'Tahan di posisi atas 1-2 detik',
    },
    {
      'name': 'Wall Sit',
      'repsBase': 1, // Kita gunakan detik untuk reps jika gerakan statis
      'durationBase': 35,
      'isStatic': true, // Penanda gerakan tahan/statis
      'image': 'assets/illustration/plank.webp',
      'description': 'Sandarkan punggung di dinding, tekuk lutut 90° dan tahan posisi.',
      'tip': 'Paha harus sejajar dengan lantai',
    },
    {
      'name': 'Glute Bridge',
      'repsBase': 15,
      'durationBase': 35,
      'image': 'assets/illustration/plank.webp',
      'description': 'Berbaring, tekuk lutut, angkat pinggul ke atas lalu turunkan.',
      'tip': 'Kencangkan otot glute di puncak',
    },
  ];

  static final List<Map<String, dynamic>> _chestExercises = [
    {
      'name': 'Beginner Push Up',
      'repsBase': 10,
      'durationBase': 35,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Posisi plank, turunkan dada ke lantai lalu dorong kembali ke atas.',
      'tip': 'Jaga tubuh tetap lurus dari kepala ke kaki',
    },
    {
      'name': 'Diamond Push Up',
      'repsBase': 8,
      'durationBase': 35,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Posisi push up dengan kedua tangan membentuk diamond di bawah dada.',
      'tip': 'Fokus pada kontraksi otot trisep dan dada tengah',
    },
    {
      'name': 'Wide Push Up',
      'repsBase': 10,
      'durationBase': 35,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Push up dengan tangan lebih lebar dari bahu untuk melatih dada luar.',
      'tip': 'Siku mengarah keluar saat turun',
    },
    {
      'name': 'Incline Push Up',
      'repsBase': 12,
      'durationBase': 40,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Tangan di permukaan tinggi, tubuh miring ke depan. Melatih dada bawah.',
      'tip': 'Gunakan meja atau kursi yang stabil',
    },
    {
      'name': 'Chest Dip',
      'repsBase': 10,
      'durationBase': 45,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Condongkan tubuh ke depan saat dip untuk memaksimalkan kerja otot dada.',
      'tip': 'Turun perlahan, dorong kuat ke atas',
    },
  ];

  static final List<Map<String, dynamic>> _armExercises = [
    {
      'name': 'Bicep Curl',
      'repsBase': 12,
      'durationBase': 35,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Berdiri tegak, tekuk siku angkat beban ke bahu, turunkan perlahan.',
      'tip': 'Jaga siku tetap di samping tubuh',
    },
    {
      'name': 'Tricep Dip',
      'repsBase': 10,
      'durationBase': 40,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Tangan di kursi di belakang, turunkan tubuh dengan menekuk siku.',
      'tip': 'Turun sampai siku 90 derajat',
    },
    {
      'name': 'Hammer Curl',
      'repsBase': 12,
      'durationBase': 35,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Seperti bicep curl tapi dengan posisi tangan netral.',
      'tip': 'Kontrol gerakan naik dan turun',
    },
    {
      'name': 'Overhead Tricep Ext.',
      'repsBase': 10,
      'durationBase': 40,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Angkat beban di atas kepala, tekuk siku ke belakang lalu luruskan.',
      'tip': 'Jaga lengan atas tetap di posisi',
    },
    {
      'name': 'Chin Up',
      'repsBase': 8,
      'durationBase': 45,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Gantung di palang, telapak menghadap wajah, tarik tubuh ke atas.',
      'tip': 'Fokus pada kontraksi bisep',
    },
  ];

  static final List<Map<String, dynamic>> _absExercises = [
    {
      'name': 'Plank Crunch',
      'repsBase': 10,
      'durationBase': 30,
      'image': 'assets/illustration/plank.webp',
      'description': 'Mulai posisi plank, tarik lutut ke dada secara bergantian.',
      'tip': 'Jaga punggung tetap lurus',
    },
    {
      'name': 'Sit Up',
      'repsBase': 15,
      'durationBase': 40,
      'image': 'assets/illustration/plank.webp',
      'description': 'Berbaring, tekuk lutut, angkat tubuh bagian atas ke arah lutut.',
      'tip': 'Jangan tarik leher dengan tangan',
    },
    {
      'name': 'Leg Raise',
      'repsBase': 12,
      'durationBase': 35,
      'image': 'assets/illustration/plank.webp',
      'description': 'Berbaring, angkat kedua kaki lurus ke atas lalu turunkan perlahan.',
      'tip': 'Punggung bawah menempel lantai',
    },
    {
      'name': 'Russian Twist',
      'repsBase': 20,
      'durationBase': 40,
      'image': 'assets/illustration/plank.webp',
      'description': 'Duduk miring 45°, putar badan kanan-kiri sambil kaki terangkat.',
      'tip': 'Gerakan dari inti perut, bukan tangan',
    },
    {
      'name': 'Bicycle Crunch',
      'repsBase': 16,
      'durationBase': 45,
      'image': 'assets/illustration/plank.webp',
      'description': 'Berbaring, gerakan seperti mengayuh sepeda sambil twist.',
      'tip': 'Kontrol napas di setiap gerakan',
    },
  ];

  // =========================================================================
  // FUNGSI GENERATOR UTAMA
  // =========================================================================
  
  /// Mengambil daftar gerakan dinamis berdasarkan [type], [levelAktivitas], dan [waktuLuang]
  static List<Map<String, dynamic>> generateWorkout(
    String type,
    String levelAktivitas,
    String waktuLuang,
  ) {
    List<Map<String, dynamic>> pool = [];

    // 1. Pilih pool gerakan yang sesuai
    switch (type.toLowerCase()) {
      case 'leg':
        pool = List.from(_legExercises);
        break;
      case 'chest':
        pool = List.from(_chestExercises);
        break;
      case 'arm':
        pool = List.from(_armExercises);
        break;
      case 'abs':
        pool = List.from(_absExercises);
        break;
      default:
        pool = List.from(_legExercises); // Default fallback
    }

    // 2. Modifikasi Intensitas (Repetisi) & Durasi berdasarkan Level Aktivitas
    // Alih-alih meningkatkan repetisi ke jumlah yang sangat besar (endurance),
    // kita sesuaikan beban dalam batas hipertrofi atau kekuatan yang masuk akal.
    return pool.map((exercise) {
      int baseReps = exercise['repsBase'];
      int baseDuration = exercise['durationBase'];
      bool isStatic = exercise['isStatic'] ?? false;
      
      int adjustedReps = baseReps;
      int adjustedDuration = baseDuration;

      // Logika Penyesuaian Level
      if (levelAktivitas.toLowerCase() == 'pemula') {
        if (!isStatic) adjustedReps = (baseReps * 0.7).round();
        adjustedDuration = (baseDuration * 0.8).round();
      } else if (levelAktivitas.toLowerCase() == 'lanjut' || levelAktivitas.toLowerCase() == 'profesional') {
        if (!isStatic) adjustedReps = (baseReps * 1.3).round();
        adjustedDuration = (baseDuration * 1.2).round();
      } 
      
      // 3. Modifikasi Waktu Istirahat (HIIT Logic) berdasarkan Waktu Luang
      // Alih-alih memotong gerakan (yang bisa menyebabkan ketidakseimbangan otot),
      // kita memanipulasi waktu istirahat antar set.
      int restDuration = 15; // default rest
      if (waktuLuang.contains('15 - 30')) {
        restDuration = 5; // Sangat pendek (HIIT Mode)
        adjustedDuration = (adjustedDuration * 0.9).round(); // Sedikit lebih cepat
      } else if (waktuLuang.contains('30 - 45')) {
        restDuration = 15; // Sedang
      } else {
        restDuration = 30; // Pemulihan maksimal untuk pertumbuhan kekuatan (Hypertrophy Mode)
      }

      // Format teks reps untuk ditampilkan di UI
      String repsText = '';
      if (isStatic) {
        repsText = '$adjustedDuration Detik';
      } else {
        repsText = '$adjustedReps Reps';
        if (exercise['name'].toString().contains('Lunge')) {
           repsText += ' (tiap kaki)';
        }
      }

      return {
        'name': exercise['name'],
        'reps': repsText,
        'duration': adjustedDuration,
        'restDuration': restDuration,
        'image': exercise['image'],
        'description': exercise['description'],
        'tip': exercise['tip'],
      };
    }).toList();
  }
}
