import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/sign_up/logic/onboarding_logic.dart';
import 'dashboard_screen.dart';
import 'onboarding_form.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingLogic _logic = OnboardingLogic();
  int _currentPage = 0;
  String? _selectedWaktuLuang;

  // Colors based on user specs
  final Color primaryGreen = const Color(0xFFBEFF5D);
  final Color whiteColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFF0A0518);

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // After onboarding is complete, they are already authenticated, so go to Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
              _buildStep4(),
              _buildStep5(),
            ],
          ),
          // Page Indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _currentPage == index ? primaryGreen : Colors.white54,
                      width: 2,
                    ),
                    color: _currentPage == index ? primaryGreen : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Image.asset(
            'assets/icon/fitlife.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Step 1: Welcome
  Widget _buildStep1() {
    return Stack(
      children: [
        Image(image: AssetImage("assets/background/onboardingBg.png"), fit: BoxFit.cover),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _buildLogo(),
                Text(
                  'Welcome to FitLife',
                  style: GoogleFonts.coda(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your personal fitness companion.',
                  style: GoogleFonts.allerta(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                _buildButton('Mulai', isGreen: true, onPressed: _nextPage),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: Pilih Tujuanmu
  Widget _buildStep2() {
    return Stack(
      children: [
        Image(image: AssetImage("assets/background/onboardingBg2.png"), fit: BoxFit.cover),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                Text(
                  'Pilih Tujuanmu',
                  style: GoogleFonts.allerta(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 40),
                _buildButton('Tetap fit (default)', isGreen: true, onPressed: () async {
                  await _logic.saveOnboardingData(tujuan: 'Tetap fit', tanggalLahir: null, tinggiBadan: null, beratBadan: null, jenisKelamin: null, waktuLuang: null);
                  _nextPage();
                }),
                const SizedBox(height: 16),
                _buildButton('Menurunkan berat badan', isGreen: true, onPressed: () async {
                  await _logic.saveOnboardingData(tujuan: 'Menurunkan berat badan', tanggalLahir: null, tinggiBadan: null, beratBadan: null, jenisKelamin: null, waktuLuang: null);
                  _nextPage();
                }),
                const SizedBox(height: 16),
                _buildButton('Menaikkan massa otot', isGreen: true, onPressed: () async {
                  await _logic.saveOnboardingData(tujuan: 'Menaikkan massa otot', tanggalLahir: null, tinggiBadan: null, beratBadan: null, jenisKelamin: null, waktuLuang: null);
                  _nextPage();
                }),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Step 3: Form
  Widget _buildStep3() {
    return Stack(
      children: [
         Image(image: AssetImage("assets/background/onboardingBg3.png"), fit: BoxFit.cover),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _buildLogo()),
                  const SizedBox(height: 20),
                  // Render the dedicated form widget
                  OnboardingForm(onSavedAndContinue: _nextPage),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 4: Waktu Luang
  Widget _buildStep4() {
    return Stack(
      children: [
         Image(image: AssetImage("assets/background/onboardingBg4.png"), fit: BoxFit.cover),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                Text(
                  'Waktu Luang',
                  style: GoogleFonts.allerta(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 40),
                _buildButton('10-15 menit', isGreen: _selectedWaktuLuang == '10-15 menit', onPressed: () {
                  setState(() {
                    _selectedWaktuLuang = '10-15 menit';
                  });
                }),
                const SizedBox(height: 16),
                _buildButton('20-30 menit', isGreen: _selectedWaktuLuang == '20-30 menit', onPressed: () {
                  setState(() {
                    _selectedWaktuLuang = '20-30 menit';
                  });
                }),
                const SizedBox(height: 16),
                _buildButton('30+ menit', isGreen: _selectedWaktuLuang == '30+ menit', onPressed: () {
                  setState(() {
                    _selectedWaktuLuang = '30+ menit';
                  });
                }),
                const Spacer(),
                _buildButton('Lanjut', isGreen: true, onPressed: () async {
                  if (_selectedWaktuLuang != null) {
                    await _logic.saveOnboardingData(waktuLuang: _selectedWaktuLuang, tujuan: null, tanggalLahir: null, tinggiBadan: null, beratBadan: null, jenisKelamin: null);
                    _nextPage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih waktu luang terlebih dahulu!')));
                  }
                }),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Step 5: Trust The Process
  Widget _buildStep5() {
    return Stack(
      children: [
       Image(image: AssetImage("assets/background/onboardingBg5.png"), fit: BoxFit.cover),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Spacer(),
                _buildButton('Selesai', isGreen: true, onPressed: _nextPage),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
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

  Widget _buildTextField(String hint, bool hasDropdown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: GoogleFonts.allerta(fontSize: 16, color: Colors.black54),
          ),
          if (hasDropdown)
            const Icon(Icons.keyboard_arrow_down, color: Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildButton(String text, {required bool isGreen, VoidCallback? onPressed}) {
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
        onPressed: onPressed ?? () {},
        child: Text(
          text,
          style: GoogleFonts.allerta(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
