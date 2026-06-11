import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/dashboard/logic/settings_controller.dart';
import '../../features/profile/logic/profile_account_controller.dart';
import '../components/update_email_form.dart';
import '../components/update_password_form.dart';
import '../components/global_snackbar.dart';
import '../components/profile_avatar.dart';

class ProfileAccountScreen extends StatefulWidget {
  const ProfileAccountScreen({super.key});

  @override
  State<ProfileAccountScreen> createState() => _ProfileAccountScreenState();
}

class _ProfileAccountScreenState extends State<ProfileAccountScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  final _formKey = GlobalKey<FormState>();
  late final SettingsController _settingsController;
  late final ProfileAccountController _accountController;
  final _namaController = TextEditingController();
  final _tglLahirController = TextEditingController();
  String _jenisKelamin = 'Pria';
  bool _isLoading = true;
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _settingsController = SettingsController();
    _accountController = ProfileAccountController();
    _initData();
  }

  Future<void> _initData() async {
    await _settingsController.loadAll();
    
    // Load image path from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedImagePath = prefs.getString('profile_image_path');
    
    if (mounted) {
      setState(() {
        _namaController.text = _settingsController.nama;
        _tglLahirController.text = _settingsController.tanggalLahir;
        _jenisKelamin = _settingsController.jenisKelamin;
        if (savedImagePath != null && savedImagePath.isNotEmpty) {
          _imageFile = File(savedImagePath);
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tglLahirController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', pickedFile.path);
        ProfileAvatar.imagePathNotifier.value = pickedFile.path;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initial;
    try {
      if (_tglLahirController.text.contains('/')) {
        final parts = _tglLahirController.text.split('/');
        initial = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } else {
        initial = DateTime.tryParse(_tglLahirController.text) ?? DateTime(2000, 1, 1);
      }
    } catch (_) {
      initial = DateTime(2000, 1, 1);
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: limeGreen,
              onPrimary: Colors.black,
              surface: cardColor,
              onSurface: white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: limeGreen,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tglLahirController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await _settingsController.saveProfil(
        namaBaru: _namaController.text.trim(),
        tanggalLahirBaru: _tglLahirController.text.trim(),
        jenisKelaminBaru: _jenisKelamin,
      );
      if (mounted) {
        GlobalSnackBar.show(context, 'Profil berhasil diperbarui');
        Navigator.pop(context, true);
      }
    }
  }

  void _showUpdateEmailModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateEmailForm(controller: _accountController),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _showUpdatePasswordModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdatePasswordForm(controller: _accountController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil dan Akun',
          style: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: limeGreen))
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: cardColor,
                              backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                              child: _imageFile == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: limeGreen,
                                    )
                                  : null,
                            ),
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: limeGreen,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(color: grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _namaController,
                      style: const TextStyle(color: white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: 'Masukkan nama Anda',
                        hintStyle: const TextStyle(color: grey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: limeGreen),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tanggal Lahir',
                      style: TextStyle(color: grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tglLahirController,
                      readOnly: true,
                      style: const TextStyle(color: white),
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: 'Pilih tanggal lahir',
                        hintStyle: const TextStyle(color: grey),
                        suffixIcon: const Icon(Icons.calendar_today, color: limeGreen),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: limeGreen),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal lahir tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Jenis Kelamin',
                      style: TextStyle(color: grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _jenisKelamin = 'Pria'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _jenisKelamin == 'Pria' ? limeGreen : cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _jenisKelamin == 'Pria' ? limeGreen : borderColor,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Pria',
                                  style: TextStyle(
                                    color: _jenisKelamin == 'Pria' ? Colors.black : white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _jenisKelamin = 'Wanita'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _jenisKelamin == 'Wanita' ? limeGreen : cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _jenisKelamin == 'Wanita' ? limeGreen : borderColor,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Wanita',
                                  style: TextStyle(
                                    color: _jenisKelamin == 'Wanita' ? Colors.black : white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Keamanan Akun',
                      style: TextStyle(
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Email',
                                      style: TextStyle(color: grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      FirebaseAuth.instance.currentUser?.email ?? 'Tidak terhubung',
                                      style: const TextStyle(color: white, fontSize: 15, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: _showUpdateEmailModal,
                                style: TextButton.styleFrom(
                                  foregroundColor: limeGreen,
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                child: const Text('Ubah'),
                              ),
                            ],
                          ),
                          const Divider(color: borderColor, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Kata Sandi',
                                      style: TextStyle(color: grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isGoogleUser ? 'Masuk dengan Google (tidak dapat diubah)' : '••••••••',
                                      style: const TextStyle(color: white, fontSize: 15, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isGoogleUser)
                                TextButton(
                                  onPressed: _showUpdatePasswordModal,
                                  style: TextButton.styleFrom(
                                    foregroundColor: limeGreen,
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('Ubah'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).size.height * 0.10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: limeGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _save,
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
