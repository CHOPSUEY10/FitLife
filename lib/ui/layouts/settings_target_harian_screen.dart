import 'package:flutter/material.dart';
import '../../features/dashboard/logic/settings_controller.dart';
import '../components/global_snackbar.dart';

class SettingsTargetHarianScreen extends StatefulWidget {
  const SettingsTargetHarianScreen({super.key});

  @override
  State<SettingsTargetHarianScreen> createState() => _SettingsTargetHarianScreenState();
}

class _SettingsTargetHarianScreenState extends State<SettingsTargetHarianScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  final _formKey = GlobalKey<FormState>();
  late final SettingsController _controller;
  final _langkahController = TextEditingController();
  final _kaloriController = TextEditingController();
  final _durasiController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _initData();
  }

  Future<void> _initData() async {
    await _controller.loadAll();
    if (mounted) {
      setState(() {
        _langkahController.text = _controller.targetLangkah.toString();
        _kaloriController.text = _controller.targetKalori.toStringAsFixed(0);
        _durasiController.text = _controller.targetDurasiLatihan.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _langkahController.dispose();
    _kaloriController.dispose();
    _durasiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final langkah = int.parse(_langkahController.text);
      final kalori = double.parse(_kaloriController.text);
      final durasi = int.parse(_durasiController.text);
      await _controller.saveTargetHarian(
        langkah: langkah,
        kalori: kalori,
        durasi: durasi,
      );
      if (mounted) {
        GlobalSnackBar.show(context, 'Target Harian berhasil diperbarui');
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Target Harian',
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
                    const Text(
                      'Tentukan target aktivitas harian Anda untuk melacak kemajuan latihan secara efektif.',
                      style: TextStyle(color: grey, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Target Langkah Harian',
                      style: TextStyle(color: grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _langkahController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: 'Contoh: 10000',
                        hintStyle: const TextStyle(color: grey),
                        suffixText: 'langkah',
                        suffixStyle: const TextStyle(color: limeGreen),
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
                          return 'Target langkah tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Masukkan jumlah langkah yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Target Pembakaran Kalori',
                      style: TextStyle(color: grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _kaloriController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: 'Contoh: 500',
                        hintStyle: const TextStyle(color: grey),
                        suffixText: 'kkal',
                        suffixStyle: const TextStyle(color: limeGreen),
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
                          return 'Target kalori tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Masukkan kalori yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Target Durasi Latihan',
                      style: TextStyle(color: grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _durasiController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: 'Contoh: 45',
                        hintStyle: const TextStyle(color: grey),
                        suffixText: 'menit',
                        suffixStyle: const TextStyle(color: limeGreen),
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
                          return 'Target durasi tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Masukkan durasi yang valid';
                        }
                        return null;
                      },
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
                          'Simpan Target',
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
