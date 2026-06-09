import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/sign_up/logic/onboarding_logic.dart';
import '../../core/service/firebase_sync_service.dart';
import 'main_screen.dart';
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
  String _selectedLevel = 'Pemula';

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
      // Force sync on onboarding completion
      FirebaseSyncService.instance.syncUserData(force: true);
      // After onboarding is complete, they are already authenticated, so go to MainScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
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
              _buildStep3(),
              _buildStepActivityLevel(),
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
                4,
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

  // Step 4: Activity Level Selection
  Widget _buildStepActivityLevel() {
    final List<Map<String, String>> levels = [
      {
        'name': 'Pemula',
        'desc': 'Baru memulai perjalanan olahraga atau kembali aktif setelah istirahat lama.',
        'icon': '🌱',
        'intensity': 'Intensitas: Ringan'
      },
      {
        'name': 'Menengah',
        'desc': 'Sudah terbiasa berolahraga 1-3 kali dalam seminggu secara teratur.',
        'icon': '🔥',
        'intensity': 'Intensitas: Sedang'
      },
      {
        'name': 'Mahir / Atlet',
        'desc': 'Berolahraga intensif 4-6 kali seminggu dengan stamina dan kekuatan tinggi.',
        'icon': '⚡',
        'intensity': 'Intensitas: Tinggi'
      },
    ];

    return Stack(
      children: [
        const Image(image: AssetImage("assets/background/onboardingBg2.png"), fit: BoxFit.cover),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: _buildLogo()),
                Text(
                  'Pilih Level Aktivitas',
                  style: GoogleFonts.coda(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih level yang paling sesuai dengan kondisi fisik Anda saat ini.',
                  style: GoogleFonts.allerta(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final lvl = levels[index];
                      final isSelected = _selectedLevel == lvl['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLevel = lvl['name']!;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryGreen.withOpacity(0.15) : const Color(0xFF1A1A2E).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? primaryGreen : const Color(0xFF2A2A3E),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lvl['icon']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lvl['name']!,
                                      style: TextStyle(
                                        color: isSelected ? primaryGreen : Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lvl['desc']!,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      lvl['intensity']!,
                                      style: TextStyle(
                                        color: isSelected ? primaryGreen.withOpacity(0.9) : primaryGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: primaryGreen, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildButton(
                  'Lanjut',
                  isGreen: true,
                  onPressed: () async {
                    await _logic.saveLevelAktivitas(_selectedLevel);
                    _nextPage();
                  },
                ),
                const SizedBox(height: 48),
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
