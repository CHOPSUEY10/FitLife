import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/sign_up/logic/onboarding_logic.dart';

class OnboardingForm extends StatefulWidget {
  final VoidCallback onSavedAndContinue;

  const OnboardingForm({super.key, required this.onSavedAndContinue});

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  final OnboardingLogic _logic = OnboardingLogic();
  
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _selectedGender;
  String? _selectedWaktuLuang;
  
  final Color primaryGreen = const Color(0xFFBEFF5D);
  final Color whiteColor = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('Tanggal Lahir'),
        _buildDateField(),
        const SizedBox(height: 16),
        _buildLabel('Tinggi Badan (Cm)'),
        _buildTextField(_heightController, 'Misal: 170', isNumber: true),
        const SizedBox(height: 16),
        _buildLabel('Berat Badan (Kg)'),
        _buildTextField(_weightController, 'Misal: 65', isNumber: true),
        const SizedBox(height: 16),
        _buildLabel('Jenis Kelamin'),
        _buildDropdownGender(),
        const SizedBox(height: 16),
        _buildLabel('Waktu Luang Latihan'),
        _buildDropdownWaktuLuang(),
        const SizedBox(height: 30),
        _buildButton('Lanjut', isGreen: true, onPressed: () async {
          if (_dobController.text.isEmpty || _heightController.text.isEmpty || _weightController.text.isEmpty || _selectedGender == null || _selectedWaktuLuang == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi semua data terlebih dahulu!')));
            return;
          }
          // Trigger the logic to save metrics to SQLite
          await _logic.saveOnboardingData(
            tujuan: null, 
            tanggalLahir: _dobController.text,
            tinggiBadan: double.tryParse(_heightController.text),
            beratBadan: double.tryParse(_weightController.text),
            jenisKelamin: _selectedGender,
            waktuLuang: _selectedWaktuLuang,
          );
          // Navigate to next page
          widget.onSavedAndContinue();
        }),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.allerta(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _dobController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
          });
        }
      },
      decoration: InputDecoration(
        hintText: 'Pilih Tanggal',
        hintStyle: GoogleFonts.allerta(color: Colors.black54),
        filled: true,
        fillColor: whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.allerta(color: Colors.black54),
        filled: true,
        fillColor: whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownGender() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      items: <String>['Pria', 'Wanita']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: GoogleFonts.allerta()),
        );
      }).toList(),
      decoration: InputDecoration(
        hintText: 'Pilih',
        hintStyle: GoogleFonts.allerta(color: Colors.black54),
        filled: true,
        fillColor: whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownWaktuLuang() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedWaktuLuang,
      onChanged: (String? newValue) {
        setState(() {
          _selectedWaktuLuang = newValue;
        });
      },
      items: <String>['15 - 30 menit', '30 - 45 menit', '> 45 menit']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: GoogleFonts.allerta()),
        );
      }).toList(),
      decoration: InputDecoration(
        hintText: 'Pilih Waktu Luang',
        hintStyle: GoogleFonts.allerta(color: Colors.black54),
        filled: true,
        fillColor: whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton(String text, {required bool isGreen, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isGreen ? primaryGreen : whiteColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.allerta(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
