import 'package:flutter/material.dart';
import '../../features/dashboard/logic/settings_controller.dart';

class SettingsDataFisikScreen extends StatefulWidget {
  const SettingsDataFisikScreen({Key? key}) : super(key: key);

  @override
  State<SettingsDataFisikScreen> createState() => _SettingsDataFisikScreenState();
}

class _SettingsDataFisikScreenState extends State<SettingsDataFisikScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  final _formKey = GlobalKey<FormState>();
  late final SettingsController _controller;
  final _tinggiController = TextEditingController();
  final _beratController = TextEditingController();
  bool _isLoading = true;

  double _bmi = 0;
  String _bmiKategori = '';

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
        _tinggiController.text = _controller.tinggiBadan.toStringAsFixed(0);
        _beratController.text = _controller.beratBadan.toStringAsFixed(0);
        _bmi = _controller.bmi;
        _bmiKategori = _controller.bmiKategori;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tinggiController.dispose();
    _beratController.dispose();
    super.dispose();
  }

  void _updateBmi() {
    final tinggi = double.tryParse(_tinggiController.text) ?? 0;
    final berat = double.tryParse(_beratController.text) ?? 0;
    if (tinggi > 0 && berat > 0) {
      final tinggiM = tinggi / 100;
      final computedBmi = berat / (tinggiM * tinggiM);
      String cat = '';
      if (computedBmi < 18.5) {
        cat = 'Kurus';
      } else if (computedBmi < 25) {
        cat = 'Normal';
      } else if (computedBmi < 30) {
        cat = 'Kelebihan Berat';
      } else {
        cat = 'Obesitas';
      }
      setState(() {
        _bmi = computedBmi;
        _bmiKategori = cat;
      });
    } else {
      setState(() {
        _bmi = 0;
        _bmiKategori = '-';
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final tinggi = double.parse(_tinggiController.text);
      final berat = double.parse(_beratController.text);
      await _controller.saveDataFisik(tinggi: tinggi, berat: berat);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Fisik berhasil disimpan'),
            backgroundColor: limeGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
          'Data Fisik',
          style: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: limeGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Indeks Massa Tubuh (BMI) Anda',
                            style: TextStyle(color: grey, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _bmi > 0 ? _bmi.toStringAsFixed(1) : '-',
                            style: const TextStyle(
                              color: limeGreen,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: _bmiKategori == 'Normal'
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : _bmiKategori == 'Kurus'
                                      ? Colors.orange.withValues(alpha: 0.2)
                                      : Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _bmiKategori,
                              style: TextStyle(
                                color: _bmiKategori == 'Normal'
                                    ? Colors.greenAccent
                                    : _bmiKategori == 'Kurus'
                                        ? Colors.orangeAccent
                                        : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Tinggi Badan (cm)',
                      style: TextStyle(color: grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tinggiController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: white),
                      onChanged: (_) => _updateBmi(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: 'Contoh: 170',
                        hintStyle: const TextStyle(color: grey),
                        suffixText: 'cm',
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
                          return 'Tinggi badan tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Berat Badan (kg)',
                      style: TextStyle(color: grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _beratController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: white),
                      onChanged: (_) => _updateBmi(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: 'Contoh: 65',
                        hintStyle: const TextStyle(color: grey),
                        suffixText: 'kg',
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
                          return 'Berat badan tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
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
                  ],
                ),
              ),
            ),
    );
  }
}
