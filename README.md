#FitLife

A new Flutter project.
Tentu, ini adalah draf `README.md` yang lengkap dan sistematis. File ini dirancang agar teman Anda bisa mengikuti langkah-langkah instalasi manual yang sudah kita lalui tanpa mengalami kendala "trial and error" yang sama.

---

# 🚀 Panduan Instalasi Flutter & Manual Android SDK (Tanpa Android Studio)

Dokumen ini berisi panduan langkah demi langkah untuk melakukan instalasi Flutter SDK dan Android Toolchain secara manual guna menghemat ruang penyimpanan.

---

## 📋 Prasyarat Sistem
*   **Sistem Operasi:** Windows 10/11 (64-bit).
*   **Ruang Disk:** Minimal 10-15 GB.
*   **Koneksi Internet:** Stabil untuk mengunduh SDK.

---

## 🛠 Langkah 1: Instalasi Git & Java (JDK)
Flutter membutuhkan Git untuk manajemen versi dan Java untuk membangun aplikasi Android.

1.  **Instal Git:** Unduh dan instal [Git for Windows](https://git-scm.com/).
2.  **Instal JDK 17 (LTS):** 
    *   Unduh [Adoptium Temurin JDK 17](https://adoptium.net/temurin/releases/?version=17).
    *   **Penting:** Gunakan versi 17 atau 21 untuk stabilitas maksimal. Jangan gunakan versi terbaru (seperti Java 25) karena sering terjadi konflik dengan Gradle.

---

## 🐦 Langkah 2: Instalasi Flutter SDK
1.  Buat folder di `C:\src\android_project`.
2.  Unduh [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) dan ekstrak ke folder tersebut.
3.  Pastikan file `flutter.bat` ada di dalam folder `C:\src\android_project\flutter\bin`.

---

## 🤖 Langkah 3: Setup Manual Android SDK (Ringan)
Langkah ini menggantikan instalasi Android Studio yang berat.

1.  Buat folder induk di `C:\Android\sdk`.
2.  Unduh **Command line tools only** di bagian bawah halaman [Download Android Studio](https://developer.android.com/studio).
3.  **Struktur Folder (Sangat Krusial):**
    *   Ekstrak isi zip tersebut ke `C:\Android\sdk\cmdline-tools\latest\`.
    *   Pastikan folder `bin` dan `lib` berada langsung di bawah folder `latest`.
    *   *Struktur akhir:* `C:\Android\sdk\cmdline-tools\latest\bin\...`
4.  Buka command prompt (Admin), masuk ke folder `bin` tersebut, dan jalankan:
    
    .\sdkmanager.bat "platform-tools" "platforms;android-36" "build-tools;34.0.0" "build-tools;28.0.3"
    

---

## 🌐 Langkah 4: Konfigurasi Environment Variables
Daftarkan path berikut agar perintah bisa dipanggil dari mana saja:

| Variable | Value |
| :--- | :--- |
| **JAVA_HOME** | `C:\Program Files\Eclipse Adoptium\jdk-17.x.x` |
| **ANDROID_HOME** | `C:\Android\sdk` |

**Tambahkan ke Path (System Variable):**
*   `%JAVA_HOME%\bin`
*   `C:\src\android_project\flutter\bin`
*   `%ANDROID_HOME%\platform-tools`
*   `%ANDROID_HOME%\cmdline-tools\latest\bin`

---

## ✅ Langkah 5: Finalisasi & Lisensi
Buka Terminal baru, lalu jalankan perintah berikut secara berurutan:

1.  **Hubungkan Flutter dengan SDK:**
    ```bash
    flutter config --android-sdk C:\Android\sdk
    ```
2.  **Setujui Lisensi Android:**
    ```bash
    flutter doctor --android-licenses
    ```
    *(Ketik `y` untuk semua pertanyaan yang muncul).*
3.  **Cek Kesehatan:**
    ```bash
    flutter doctor
    ```

---

## 📱 Langkah 6: Debugging via Perangkat Fisik (Android)
Agar aplikasi bisa langsung berjalan di HP tanpa emulator:

1.  **Aktifkan Opsi Pengembang:** Ketuk *Build Number* 7x di menu *About Phone*.
2.  **Aktifkan USB Debugging.**
3.  **Aktifkan Install via USB:** (Khusus Xiaomi/Oppo/Vivo/Realme).
4.  **Colok HP ke Laptop:** Pilih mode **Transfer File**.
5.  **Running:** Di VS Code, tekan `F5`. Jika muncul pop-up izin instalasi di layar HP, segera pilih **Allow/Install**.

---

## 💡 Troubleshooting
*   **Error JAVA_HOME:** Pastikan path menunjuk ke folder induk JDK, bukan folder `bin`.
*   **Android SDK Not Found:** Jalankan ulang `flutter config --android-sdk C:\Android\sdk`.
*   **Build Failed (Java Version):** Pastikan menggunakan JDK 17. Jika sudah terlanjur instal versi lain, hapus sisa build dengan `flutter clean` sebelum mencoba lagi.

---
*Dibuat untuk mempermudah setup Flutter environment bagi pengembang yang mengutamakan efisiensi penyimpanan.*
```